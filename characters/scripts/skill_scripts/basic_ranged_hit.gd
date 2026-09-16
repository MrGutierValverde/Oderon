extends Area2D

@onready var character = $"../.."
var valid_positions = []
var offset := 16
var base_damage = 1
var range = 3
var icon = null
var base_action_point_cost = 100
var selected = false
var tags = [
	"ranged",
	"attack",
	"physical"
]
var base_scalings = {
	"strength":[1,0,0]
}
var scalings = {
	"strength":[1,0,0]
}
var targets = []
var path_to_target: Array =[]
func reset_scalings():
	scalings = base_scalings.duplicate()
func hit_targets():
	if can_be_used():
		character.energies["action_points"][0] -= base_action_point_cost
		var damage = base_damage
		var total_added_multiplier = 0
		var total_global_mutliplier = 1
		for scaling in scalings:
			damage +=scalings[scaling][0]*character.attributes[scaling]
			total_added_multiplier +=scalings[scaling][1]*character.attributes[scaling]
			total_global_mutliplier = total_global_mutliplier *(scalings[scaling][2]*character.attributes[scaling]+1)
		print("scalings ",damage," ",total_added_multiplier," ",total_global_mutliplier)
		for modifier in character.damage_modifiers:
			var parts = modifier.split("_")
			var valid = true
			for part in parts:
				# ignoramos "damage" porque forma parte del nombre de todas las claves
				if part == "damage":
					continue
				if part not in tags:
					valid = false
					break
			if valid:
				print(character.damage_modifiers[modifier][0])
				print(character.damage_modifiers[modifier][1])
				print(character.damage_modifiers[modifier][2])
				damage += character.damage_modifiers[modifier][0]
				total_added_multiplier +=character.damage_modifiers[modifier][1]-1
				total_global_mutliplier = total_global_mutliplier * character.damage_modifiers[modifier][2]

		print("tags ",damage," ",total_added_multiplier," ",total_global_mutliplier)
		damage = damage * (total_added_multiplier+1)*total_global_mutliplier
		var damages = {
			"physical":damage
		}
		for damagetype in damages:
			print(damages[damagetype])
		for target in targets:
			target.take_damage(damages)
func hit_target(target):
	if can_be_used():
		character.energies["action_points"][0] -= base_action_point_cost
		var damage = base_damage
		var total_added_multiplier = 0
		var total_global_mutliplier = 1
		for scaling in scalings:
			damage +=scalings[scaling][0]*character.attributes[scaling]
			total_added_multiplier +=scalings[scaling][1]*character.attributes[scaling]
			total_global_mutliplier = total_global_mutliplier *(scalings[scaling][2]*character.attributes[scaling]+1)
		damage = damage * (total_added_multiplier+1)*total_global_mutliplier
		target.take_damage(damage)
func can_be_used():
	if character.energies["action_points"][0] >= base_action_point_cost:
		return true
	else:
		return false

func _process(delta: float) -> void:
	if selected:
		var mouse_pos = get_global_mouse_position()
		var map_pos = character.tilemap_layer_node.local_to_map(mouse_pos)
		if map_pos in valid_positions:
			global_position = map_pos*offset
			global_position.x += offset/2
			global_position.y += offset/2

func calculate_hit_tiles():
	valid_positions.clear()
	for x in range+1:
		for y in range+1:
			var test_distance = absi(x) + absi(y)
			if test_distance <= range:
				var current_tile = character.global_position/character.tile_size
				var selected_check_tile = current_tile as Vector2i + Vector2i(x, y)
				add_walkeable_tile(selected_check_tile)
				selected_check_tile = current_tile as Vector2i + Vector2i(-x, y)
				add_walkeable_tile(selected_check_tile)
				selected_check_tile = current_tile as Vector2i + Vector2i(-x, -y)
				add_walkeable_tile(selected_check_tile)
				selected_check_tile = current_tile as Vector2i + Vector2i(x, -y)
				add_walkeable_tile(selected_check_tile)
				
func add_walkeable_tile(tile):
	if tile in character.tilemap_layer_node.get_used_cells():
			path_to_target = character.pathfinding_attack_grid.get_point_path(character.global_position/character.tile_size,tile,true)
			#Limitamos la ruta al movimiento que puede realizar la unidad
			path_to_target =path_to_target.slice(0,range+1)
			if tile*character.tile_size as Vector2 in path_to_target:
				if tile not in valid_positions:
					valid_positions.append(tile)
func show_walkeable_tiles():
	for tile in valid_positions:
		print("visual tiles",tile)
		character.visual_paths_tilemap_layer_node.set_cell(tile,0,Vector2(0,2))
func _on_body_entered(body: Node2D) -> void:
	if not targets.has(body):
		targets.append(body)
		print("New target found")
func _on_body_exited(body: Node2D) -> void:
	if targets.has(body):
		targets.erase(body)
		print("target left area")
