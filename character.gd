class_name Character
extends CharacterBody2D
signal on_turn_start
signal on_turn_end
signal on_combat_start
signal on_combat_end
signal on_kill
signal on_hit
signal before_damage_taken
signal after_damage_taken
@export var visual_paths_tilemap_layer_node: TileMapLayer = null
@export var tilemap_layer_node: TileMapLayer = null
var pathfinding_grid : AStarGrid2D = AStarGrid2D.new()
var pathfinding_attack_grid : AStarGrid2D = AStarGrid2D.new()
var tile_size = 16
@onready var players = $"../../player_characters"
@onready var enemies = $"../../enemy_characters"
var cell_impassable = "impassable"
@export var my_trun=true
@export var life = "life"
#varoable that dictates what body parts the creature has and ther life
@export var body_parts = {
	#"name of body part" = [current life of body part, max life of body part]
	"head" = [20,20,0.2],
	"body" = [30,30,0.5],
	"right_arm" = [30,30,0.3],
	"left_arm" = [30,30,0.3],
	"right_leg" = [30,30,0.3],
	"left_leg" = [30,30,0.3]
}
@export var equipment_slots = {
	"head" = "",
	"body" = "",
	"right_arm" = "",
	"left_arm" = "",
	"right_hand" = "",
	"left_hand" = "",
	"belt" = "",
	"legs" = "",
	"ring_1" = "",
	"ring_2" = "",
}
@export var knockout_life_ratio = 0.1
@export var knockout_life = 1
@export var can_be_knocked_out = true
@export var base_movement_speed = 3
@export var additive_movement_speed = 0
@export var movement_speed_multiplier = 0
@export var movement_speed = 5
@export var remaining_movement = 5

@export var energies = {
	#energy_type:[current,max,regen_per_turn]
	"life":[0.0,0.0,1.0],
	"mana":[20.0,20.0,1.0],
	"action_points":[100,125,100]
}
@export var resistances = {
	
}
@export var damage_modifiers = {
	
}
@export var parameters = {
	"attack_speed":1,
	"attack_damage":0,
	"magic_power":0,
	"armor":0,
	"dodge":0,
	"physical_precision":0,
	"magical_precision":0,
	"experience_gain":1,
	"lifespan":80,
	"age":20,
	"effective_age":20
}
@export var attributes = {
	#"name of attribute" = value
	"constitution"= 5,
	"strength"= 5,
	"dexterity"= 5,
	"intelligence"= 5,
	"faith"= 5,
	"charisma"= 5,
	"magic"= 5
}
@export var joint_modifications = {
	
}
@export var total_modifications = {
	
}
@export var temporary_modifications = {
	
}
@export var temporary_modifiers = {

}
@export var modifiers = {
	"base" = {
		"action_points"={
			"base_added":125,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"action_points_regen"={
			"base_added":100,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"experience_gain"={
			"base_added":1,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"timeflow"={
			"base_added":1,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"constitution"= {
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"strength"= {
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"dexterity"= {
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"intelligence"= {
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"faith"={
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"charisma"= {
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"magic"= {
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"life_regen"={
			"base_added":1,
			"added_multiplier":0,
			"global_multiplier":1
		}
	},
	"weapon" = {
		"attack_speed":{
			"base_added":1,
			"added_multiplier":0,
			"global_multiplier":1
		}
	},
	"level" = {
		
	},
	"buff_example"= {
		"attribute_or_variable_affectred" : {
			"base_added":0,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"life" : {
			"base_added":0,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"physical_resistance" : {
			"base_added":0,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"melee_attack_damage" : {
			"base_added":0,
			"added_multiplier":0,
			"global_multiplier":1
		},
	},
	"constitution"= {
		"effects" : {
			"base":{
				"life":[4,0,0]
			},
			#valor a añadir, de este su valor base, multiplicador aditivo y multiplicador global por punto del atributo
			"life":[4,0,0]
		},
		#el efecto anterior generaría el siguiente fragmento cuando se ejecute la función apply_attributes()
		"life" : {
			"base_added":0,
			"added_multiplier":0,
			"global_multiplier":1
		},
	},
	"magic"= {
		"effects" : {
			"base":{
				"mana":[4,0,0]
			},
			#valor a añadir, de este su valor base, multiplicador aditivo y multiplicador global por punto del atributo
			"mana":[4,0,0],
			"mana_regen":[0.2,0,0]
		},
		#el efecto anterior generaría el siguiente fragmento cuando se ejecute la función apply_attributes()
		"mana" : {
			"base_added":20,
			"added_multiplier":0,
			"global_multiplier":1
		},
	},
}
func regen_turn_start():
	for energy in energies:
		energies[energy][0]+=energies[energy][2]
		if energies[energy][0] > energies[energy][1]:
			energies[energy][0] = energies[energy][1]
func temporary_modifiers_changed():
	calculate_total_stats()
func calculate_total_stats():
	build_attributes()
	for attribute in attributes:
		apply_total_attribute_modifiers(attribute)
	calculate_permanent_modifications()
	calculate_temporary_modifications()
	build_joint_modifications()
	apply_modifiers()


func calculate_temporary_attribute_modifications():
	temporary_modifications={}
	for modifier in temporary_modifiers:
		for modification in temporary_modifiers[modifier]:
			if modification!= "effects" and modification in attributes:
				var total_value_added = temporary_modifiers[modifier][modification]["base_added"]
				var total_added_value_multiplier = temporary_modifiers[modifier][modification]["added_multiplier"]
				var total_global_value_multiplier = temporary_modifiers[modifier][modification]["global_multiplier"]
				if modification in temporary_modifications:
					temporary_modifications[modification][0] += total_value_added
					temporary_modifications[modification][1] += total_added_value_multiplier
					temporary_modifications[modification][2] = temporary_modifications[modification][2]*total_global_value_multiplier
				else:
					temporary_modifications[modification] = [total_value_added,(total_added_value_multiplier+1),total_global_value_multiplier]
func calculate_permanent_attribute_modifications():
	total_modifications={}
	for modifier in modifiers:
		for modification in modifiers[modifier]:
			if modification!= "effects" and modification in attributes:
				var total_value_added = modifiers[modifier][modification]["base_added"]
				var total_added_value_multiplier = modifiers[modifier][modification]["added_multiplier"]
				var total_global_value_multiplier = modifiers[modifier][modification]["global_multiplier"]
				if modification in total_modifications:
					total_modifications[modification][0] += total_value_added
					total_modifications[modification][1] += total_added_value_multiplier
					total_modifications[modification][2] = total_modifications[modification][2]*total_global_value_multiplier
				else:
					total_modifications[modification] = [total_value_added,(total_added_value_multiplier+1),total_global_value_multiplier]
func build_joint_attribute_modifications():
	joint_modifications={}
	for modification in total_modifications:
		if modification in attributes and modification!= "effects":
			if modification in temporary_modifications:
				joint_modifications[modification]=[0,0,0]
				joint_modifications[modification][0] = total_modifications[modification][0]+temporary_modifications[modification][0]
				joint_modifications[modification][1] = total_modifications[modification][1]+temporary_modifications[modification][1]-1
				joint_modifications[modification][2] = total_modifications[modification][2]*temporary_modifications[modification][2]
			else:
				joint_modifications[modification]=[0,0,0]
				joint_modifications[modification][0] = total_modifications[modification][0]
				joint_modifications[modification][1] = total_modifications[modification][1]
				joint_modifications[modification][2] = total_modifications[modification][2]
	for modification in temporary_modifications:
		if modification in attributes and modification!= "effects":
			if modification not in joint_modifications:
				joint_modifications[modification]=[0,0,0]
				joint_modifications[modification][0] = temporary_modifications[modification][0]
				joint_modifications[modification][1] = temporary_modifications[modification][1]
				joint_modifications[modification][2] = temporary_modifications[modification][2]

func build_attributes():
	calculate_temporary_attribute_modifications()
	calculate_permanent_attribute_modifications()
	build_joint_attribute_modifications()
	for modification in joint_modifications:
		if modification in attributes:
			attributes[modification] = (joint_modifications[modification][0])*(joint_modifications[modification][1])*joint_modifications[modification][2]
func apply_total_attribute_modifiers(attribute):
	if attribute in modifiers:
			print(attribute)
			for effect in modifiers[attribute]["effects"]:
				print(effect)
				if effect != "base":
					var total_attribute = (joint_modifications[attribute][0])*(joint_modifications[attribute][1])*joint_modifications[attribute][2]
					
					var base_added = modifiers[attribute]["effects"][effect][0]*total_attribute
					var added_multiplier = modifiers[attribute]["effects"][effect][1]*total_attribute
					var global_multiplier = 1+modifiers[attribute]["effects"][effect][2]*total_attribute
					print("base_added", base_added)
					print("added_multiplier", added_multiplier)
					print("global_multiplier", global_multiplier)
					temporary_modifiers[attribute] = {}
					temporary_modifiers[attribute][effect]={
						"base_added":base_added,
						"added_multiplier":added_multiplier,
						"global_multiplier":global_multiplier
					}

func build_joint_modifications():
	joint_modifications={}
	for modification in total_modifications:
		if modification!= "effects":
			if modification in temporary_modifications:
				joint_modifications[modification]=[0,0,0]
				joint_modifications[modification][0] = total_modifications[modification][0]+temporary_modifications[modification][0]
				joint_modifications[modification][1] = total_modifications[modification][1]+temporary_modifications[modification][1]-1
				joint_modifications[modification][2] = total_modifications[modification][2]*temporary_modifications[modification][2]
			else:
				joint_modifications[modification]=[0,0,0]
				joint_modifications[modification][0] = total_modifications[modification][0]
				joint_modifications[modification][1] = total_modifications[modification][1]
				joint_modifications[modification][2] = total_modifications[modification][2]
	for modification in temporary_modifications:
		if modification!= "effects":
			if modification not in joint_modifications:
				joint_modifications[modification]=[0,0,0]
				joint_modifications[modification][0] = temporary_modifications[modification][0]
				joint_modifications[modification][1] = temporary_modifications[modification][1]
				joint_modifications[modification][2] = temporary_modifications[modification][2]

func apply_modifiers():
	for modification in joint_modifications:
		if modification!= "effects":
			if modification in attributes:
				attributes[modification] = (joint_modifications[modification][0])*(joint_modifications[modification][1])*joint_modifications[modification][2]
			elif modification in energies:
				var old_max_energy =energies[modification][1]
				var energy_to_max_ratio =1
				if old_max_energy >0:
					energy_to_max_ratio=energies[modification][0]/old_max_energy
				energies[modification][1] = (joint_modifications[modification][0])*(joint_modifications[modification][1])*joint_modifications[modification][2]
				energies[modification][0] = energies[modification][1]*energy_to_max_ratio
			elif "_regen" in modification:
				energies[modification.replace("_regen","")][2] = (joint_modifications[modification][0])*(joint_modifications[modification][1])*joint_modifications[modification][2]
			elif "_resistance" in modification:
				resistances[modification] = (joint_modifications[modification][0])*(joint_modifications[modification][1])*joint_modifications[modification][2]
			elif "_damage" in modification:
				damage_modifiers[modification] = [joint_modifications[modification][0],joint_modifications[modification][1],joint_modifications[modification][2]]
			else:
				parameters[modification] = (joint_modifications[modification][0])*(joint_modifications[modification][1])*joint_modifications[modification][2]
func calculate_permanent_modifications():
	total_modifications={}
	for modifier in modifiers:
		for modification in modifiers[modifier]:
			if modification!= "effects":
				var total_value_added = modifiers[modifier][modification]["base_added"]
				var total_added_value_multiplier = modifiers[modifier][modification]["added_multiplier"]
				var total_global_value_multiplier = modifiers[modifier][modification]["global_multiplier"]
				if modification in total_modifications:
					total_modifications[modification][0] += total_value_added
					total_modifications[modification][1] += total_added_value_multiplier
					total_modifications[modification][2] = total_modifications[modification][2]*total_global_value_multiplier
				else:
					total_modifications[modification] = [total_value_added,(total_added_value_multiplier+1),total_global_value_multiplier]
func calculate_temporary_modifications():
	temporary_modifications={}
	for modifier in temporary_modifiers:
		for modification in temporary_modifiers[modifier]:
			if modification!= "effects":
				var total_value_added = temporary_modifiers[modifier][modification]["base_added"]
				var total_added_value_multiplier = temporary_modifiers[modifier][modification]["added_multiplier"]
				var total_global_value_multiplier = temporary_modifiers[modifier][modification]["global_multiplier"]
				if modification in temporary_modifications:
					temporary_modifications[modification][0] += total_value_added
					temporary_modifications[modification][1] += total_added_value_multiplier
					temporary_modifications[modification][2] = temporary_modifications[modification][2]*total_global_value_multiplier
				else:
					temporary_modifications[modification] = [total_value_added,(total_added_value_multiplier+1),total_global_value_multiplier]
func update_map_combat_start():
	#visual_path_line2D.global_position = Vector2(tile_size/2.0,tile_size/2.0)
	pathfinding_grid.region = tilemap_layer_node.get_used_rect()
	pathfinding_grid.cell_size = Vector2(tile_size,tile_size)
	pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinding_grid.update()
	var ocuppied_cells = []
	for player in players.get_children():
		var check_position = player.global_position
		if check_position != global_position:
			ocuppied_cells.append(tilemap_layer_node.local_to_map(check_position))
	for enemy in enemies.get_children():
		var check_position = enemy.global_position
		if check_position != global_position:
			ocuppied_cells.append(tilemap_layer_node.local_to_map(check_position))
	#hay que recorrer las tiles del tilemap y comprobar si son muros y asignarlos para que el algoritmo los reconozca
	for cell in tilemap_layer_node.get_used_cells():
		var tile_data = tilemap_layer_node.get_cell_tile_data(cell)
		if cell in ocuppied_cells:
			pathfinding_grid.set_point_solid(cell,true)
		elif tile_data:
			var impassable = tile_data.get_custom_data(cell_impassable)
			if impassable:
				pathfinding_grid.set_point_solid(cell,true)
			else:
				pathfinding_grid.set_point_solid(cell,false)
		else:
			pathfinding_grid.set_point_solid(cell,false)
	#move_character_combat()
func update_attack_map_combat_start():
	#visual_path_line2D.global_position = Vector2(tile_size/2.0,tile_size/2.0)
	pathfinding_attack_grid.region = tilemap_layer_node.get_used_rect()
	pathfinding_attack_grid.cell_size = Vector2(tile_size,tile_size)
	pathfinding_attack_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinding_attack_grid.update()
	#hay que recorrer las tiles del tilemap y comprobar si son muros y asignarlos para que el algoritmo los reconozca
	for cell in tilemap_layer_node.get_used_cells():
		var tile_data = tilemap_layer_node.get_cell_tile_data(cell)
		if tile_data:
			var impassable = tile_data.get_custom_data(cell_impassable)
			if impassable:
				pathfinding_attack_grid.set_point_solid(cell,true)
			else:
				pathfinding_attack_grid.set_point_solid(cell,false)
		else:
			pathfinding_attack_grid.set_point_solid(cell,false)
	#move_character_combat()
func _ready():
	calculate_total_stats()
	#calculate_attributes()
	#apply_attributes()
	#caclulate_max_life()
	#calculate_energies()
	#calculate_parameter("attack_speed")
func caclulate_movement_speed():
	movement_speed = (base_movement_speed+additive_movement_speed)*movement_speed_multiplier
func calculate_body_part_max_life():
	for i in body_parts:
		body_parts[i][1] = energies[life][1]*body_parts[i][2]

func calculate_knockout_life():
	knockout_life = energies[life][1]*knockout_life_ratio
func take_damage(damages):
	before_damage_taken.emit()
	var total_damage = 0
	for damage in damages:
		var resistance_name = damage+"_resistance"
		if resistance_name in resistances:
			var reduced_damage = damages[damage]*(1-resistances[resistance_name])
			if reduced_damage > 0:
				total_damage+=reduced_damage
		else:
			total_damage+=damages[damage]
	energies["life"][0] = energies["life"][0] - total_damage
	after_damage_taken.emit()
