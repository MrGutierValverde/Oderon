extends Character



@onready var skills_node = $Skills
@export var target = null

var old_target = null
var moving = false

var path_to_target: Array =[]

var valid_positions = []
@onready var raycast = $RayCast2D
var animation_speed = 9

var in_combat = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	calculate_total_stats()
	calculate_body_part_max_life()
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	combat_start()
func search_target():
	var first_check = true
	var distance_to_player_character=0
	for player in players.get_children():
		print(player)
		var check_target = tilemap_layer_node.local_to_map(player.global_position)
		if first_check:
			distance_to_player_character = calculate_distance_to_taregt(check_target)
			first_check = false
			target = check_target
		else:
			var check_distance = calculate_distance_to_taregt(check_target)
			if distance_to_player_character>check_distance:
				distance_to_player_character=check_distance
				target = check_target
				
func check_attack():
	var skills_in_range = []
	var player_target = null
	
	for player in players.get_children():
		var check_target = tilemap_layer_node.local_to_map(player.global_position)
		if check_target == target:
			player_target = player
	for skill in skills_node.get_children():
		skill.calculate_hit_tiles()
		print("check_skill_target",target)
		for position in valid_positions:
			print("check_skill_valid_positions",position)
		if target in skill.valid_positions:
			skills_in_range.append(skill)
	for skill in skills_in_range:
		if skill.can_be_used() and player_target != null:
			skill.global_position = player_target.global_position
			await get_tree().create_timer(0.1).timeout
			skill.hit_targets()
	

func calculate_route():
	if target != null:
		path_to_target = pathfinding_grid.get_point_path(global_position/tile_size,target,true)
		#Limitamos la ruta al movimiento que puede realizar la unidad
		path_to_target =path_to_target.slice(0,remaining_movement+1)
		#visual_path_line2D.points = path_to_target
func calculate_distance_to_taregt(check_target):
	#Calculamos el camino a un objetivo
	path_to_target = pathfinding_grid.get_point_path(global_position/tile_size,check_target,true)
	return path_to_target.size()
func move_character_combat():
	if target != null:
		calculate_route()
		while path_to_target.size()>1:
			
			
			path_to_target.remove_at(0)
			var go_to_pos: Vector2 = path_to_target[0]+Vector2(tile_size/2.0,tile_size/2.0)
			
			if go_to_pos.x != global_position.x:
				$Sprite2D.flip_h = false if go_to_pos.x > global_position.x else true
			raycast.target_position = global_position.direction_to(go_to_pos) * tile_size
			raycast.force_raycast_update()
			if raycast.is_colliding():
				return
			var tween = create_tween()
			tween.tween_property(self, "position",
				go_to_pos, 1.0/animation_speed).set_trans(Tween.TRANS_LINEAR)
			moving = true
			remaining_movement -=1
			await tween.finished
			
			
			#global_position = go_to_pos
			
			#visual_path_line2D.points=path_to_target
		moving = false
func calculate_walkeable_tiles():
	valid_positions.clear()
	for x in remaining_movement+1:
		for y in remaining_movement+1:
			var test_distance = absi(x) + absi(y)
			if test_distance <= remaining_movement:
				var current_tile = global_position/tile_size
				var selected_check_tile = current_tile as Vector2i + Vector2i(x, y)
				add_walkeable_tile(selected_check_tile)
				selected_check_tile = current_tile as Vector2i + Vector2i(-x, y)
				add_walkeable_tile(selected_check_tile)
				selected_check_tile = current_tile as Vector2i + Vector2i(-x, -y)
				add_walkeable_tile(selected_check_tile)
				selected_check_tile = current_tile as Vector2i + Vector2i(x, -y)
				add_walkeable_tile(selected_check_tile)
func add_walkeable_tile(tile):
	if tile in tilemap_layer_node.get_used_cells():
			path_to_target = pathfinding_grid.get_point_path(global_position/tile_size,tile,true)
			#Limitamos la ruta al movimiento que puede realizar la unidad
			path_to_target =path_to_target.slice(0,remaining_movement+1)
			if tile*tile_size as Vector2 in path_to_target:
				valid_positions.append(tile)

func combat_start():
	update_attack_map_combat_start()
	my_trun=false
	update_map_combat_start()
func end_turn():
	my_trun = false
	#selected = false
	#selectable = false
	#visual_path_line2D.clear_points()
	#clear_walkeable_tiles()
	print("turn ended")
	on_turn_end.emit()
func start_turn():
	update_map_combat_start()
	regen_turn_start()
	my_trun = true
	remaining_movement = movement_speed
	on_turn_start.emit()

func act():
	search_target()
	await move_character_combat()
	await get_tree().create_timer(0.1).timeout
	await check_attack()
	end_turn()
func combat_end():
	in_combat = false
	on_combat_end.emit()
func hit():
	on_hit.emit(target)
