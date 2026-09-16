extends Node2D
@onready var other_characters = $other_characters
@onready var player_characters = $player_characters
@onready var enemy_characters = $enemy_characters
@onready var inventory = $Inventory
var combat = true
@export var selected_player_character = null
signal selected_changed
var current_turn = "player"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func select(target):
	selected_player_character = target
	selected_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func start_enemy_turn():
	for enemy in enemy_characters.get_children():
		enemy.start_turn()
	check_enemy_turn()
func check_enemy_turn():
	for enemy in enemy_characters.get_children():
		if enemy.my_trun:
			print("Enemy turn")
			await enemy.act()
	end_enemy_turn()
func end_enemy_turn():
	current_turn = "player"
	start_player_turn()
func start_player_turn():
	for player_character in player_characters.get_children():
		player_character.start_turn()
func end_player_turn():
	if current_turn == "player":
		for player_character in player_characters.get_children():
			player_character.end_turn()
		if other_characters.get_children().size() > 0:
			current_turn = "other"
		else:
			current_turn = "enemy"
			start_enemy_turn()
func _input(event: InputEvent):
	if event.is_action_pressed("open_inentory"):
		if Global.invetory_visible:
			Global.invetory_visible = false
		else:
			Global.invetory_visible = true
		inventory.visible = Global.invetory_visible
		if selected_player_character != null:
			selected_player_character.update_equipment_and_slot_visibility()
func _on_button_pressed() -> void:
	end_player_turn()
