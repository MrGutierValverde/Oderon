class_name Item
extends Node2D

@export var type = "generic"
@export var price = 100
@export var slot = "ring"
@export var rune_multiplier = 1 #Multiplayer on the effect of runes Will be 0.5 for one handed weapons and 1 for two handed (except some uniques)
@export var modifiers = {}
@export var eqquiped = false
@onready var character = $"../.."
var draggable = false
var is_inside_droppeable = false
var body_ref
var offset: Vector2
var initialPos: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
