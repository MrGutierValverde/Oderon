extends Character

var animation_speed = 6
var moving = false
var move_character = false

var movement = Vector2.RIGHT
var in_combat = false
@onready var base_node =$"../.."
@onready var skills_node = $Skills
@onready var skill_menu = $SkillMenu
@onready var item_slots = $ItemSlots
@onready var equipment = $Equipment
var selected_skill = null

var selected = false
var confirm = false

@onready var raycast = $RayCast2D


@export var target = null
var old_target = null
@export var visual_path_line2D : Line2D = null


var path_to_target: Array =[]

var valid_positions = []

func update_equipment_slots():
	var slot_distance = 0
	for part in equipment_slots:
		var slot_scene = preload("res://characters/utils/item_slot.tscn")
		var slot = slot_scene.instantiate()
		print(part)
		slot.slot = part
		slot.position.x += slot_distance
		slot_distance += 40
		item_slots.add_child(slot)
	for child in item_slots.get_children():
		child.update_label()
		print(child.slot)
func update_equipment_and_slot_visibility():
	if selected:
		item_slots.visible = Global.invetory_visible
		equipment.visible = Global.invetory_visible
		inventory_disabler(false)
func inventory_disabler(inventory_state):
		for slot in item_slots.get_children():
			slot.get_child(0).disabled = inventory_state
func equip_item(item):
	if equipment_slots[item.slot] != "":
		var inventory_node = $"../../Inventory"
		var old_item_node = inventory_node.get_node(""+equipment_slots[item.slot])
		unequip_item(old_item_node)
		old_item_node.body_ref = inventory_node
		old_item_node.move_to_visual_inventory()
	print("Equipped item", item.name)
	temporary_modifiers[item.slot] = item.modifiers
	equipment_slots[item.slot] = item.name
	item.equipped_to = name
	temporary_modifiers_changed()
func unequip_item(item):
	print("Unequipped item", item.name)
	temporary_modifiers[item.slot] = {}
	equipment_slots[item.slot] = ""
	item.equipped_to = ""
	temporary_modifiers_changed()
func _ready():
	update_equipment_slots()
	inventory_disabler(true)
	base_node.selected_changed.connect(_on_character_changed)
	calculate_total_stats()
	calculate_body_part_max_life()
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	combat_start()
func _on_character_changed():
	
	if not base_node.selected_player_character == self:
		print("changed")
		old_target=null
		selected = false
		clear_walkeable_tiles()
		clear_selected_skill()
		inventory_disabler(true)
func open_skill_menu():
	clear_walkeable_tiles()
	clear_selected_skill()
	skill_menu.visible = true
	
	var container = skill_menu.get_node("VBoxContainer")
	
	# Limpiar botones anteriores
	for child in container.get_children():
		child.queue_free()
	
	# Crear un botón por cada skill

	for skill in skills_node.get_children():
		var btn = Button.new()
		btn.text = skill.name
		container.add_child(btn)
		
		btn.pressed.connect(func():
			select_skill(skill)
		)
	var btn_cancel = Button.new()
	btn_cancel.text = "cancelar"
	container.add_child(btn_cancel)
		
	btn_cancel.pressed.connect(func():
		clear_selected_skill()
	)
func clear_selected_skill():
	if selected_skill:
		selected_skill.visible = false
		selected_skill.selected = false
	selected_skill = null
	skill_menu.visible = false
	clear_walkeable_tiles()
func select_skill(skill):
	clear_walkeable_tiles()
	selected_skill = skill
	skill.selected = true
	skill.visible = true
	skill.calculate_hit_tiles()
	skill.show_walkeable_tiles()
	print("Skill seleccionada:", skill.name)
	skill_menu.visible = false

func _input(event: InputEvent):
	if selected_skill != null and event.is_action_pressed("left_click"):
		selected_skill.hit_targets()
	if event.is_action_pressed("right_click") and base_node.selected_player_character == self:
		open_skill_menu()
		clear_walkeable_tiles()
	if event.is_action_pressed("escape") or event.is_action_pressed("right_click"):
		selected = false
		clear_walkeable_tiles()
		old_target=null
	if selected and event.is_action_pressed("left_click") and my_trun and !moving and selected_skill == null:
		
		target = tilemap_layer_node.local_to_map(get_global_mouse_position())
		if target == old_target:
			clear_walkeable_tiles()
			move_character_combat()
		else:
			calculate_route()
		old_target = target
	if event.is_action_released("move_up") or event.is_action_released("move_down") or event.is_action_released("move_left") or event.is_action_released("move_right"):
		move_character=false
	if moving:
		return
	if event.is_action_pressed("move_up"):
		movement = Vector2.UP
		move_character = true
	if event.is_action_pressed("move_down"):
		movement = Vector2.DOWN
		move_character = true
	if event.is_action_pressed("move_left"):
		movement = Vector2.LEFT
		move_character = true
	if event.is_action_pressed("move_right"):
		movement = Vector2.RIGHT
		move_character = true

func move(movement):
	if !moving:
		raycast.target_position = movement * tile_size
		raycast.force_raycast_update()
		if !raycast.is_colliding():
			var tween = create_tween()
			tween.tween_property(self, "position",
				position + movement *    tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_LINEAR)
			moving = true
			await tween.finished
			moving = false


func calculate_route():
	visual_path_line2D.global_position = Vector2(tile_size/2.0,tile_size/2.0)
	path_to_target = pathfinding_grid.get_point_path(global_position/tile_size,target,true)
	#Limitamos la ruta al movimiento que puede realizar la unidad
	path_to_target =path_to_target.slice(0,remaining_movement+1)
	visual_path_line2D.points = path_to_target
	
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
			
			visual_path_line2D.points=path_to_target
		moving = false
func calculate_walkeable_tiles():
	update_map_combat_start()
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
	if tile in tilemap_layer_node.get_used_cells() and tile not in valid_positions:
			path_to_target = pathfinding_grid.get_point_path(global_position/tile_size,tile,true)
			#Limitamos la ruta al movimiento que puede realizar la unidad
			path_to_target =path_to_target.slice(0,remaining_movement+1)
			if tile*tile_size as Vector2 in path_to_target:
				valid_positions.append(tile)
func show_walkeable_tiles():
	for tile in valid_positions:
		print(tile)
		visual_paths_tilemap_layer_node.set_cell(tile,0,Vector2(0,3))
func clear_walkeable_tiles():
	visual_paths_tilemap_layer_node.clear()
func _physics_process(delta: float) -> void:
	if move_character and !in_combat:
		move(movement)
		
func end_turn():
	my_trun = false
	selected = false

	visual_path_line2D.clear_points()
	clear_walkeable_tiles()
	print("turn ended")
	on_turn_end.emit()
	clear_selected_skill()
func start_turn():
	update_map_combat_start()
	regen_turn_start()
	my_trun = true
	remaining_movement = movement_speed
	on_turn_start.emit()
func combat_start():
	update_attack_map_combat_start()
	start_turn()
	in_combat = true
	update_map_combat_start()
	on_combat_start.emit()
func combat_end():
	in_combat = false
	on_combat_end.emit()
func hit():
	on_hit.emit(target)



func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click") and my_trun and !moving:
		selected = true
		base_node.select(self)
		calculate_walkeable_tiles()
		show_walkeable_tiles()
		print("selected!")
