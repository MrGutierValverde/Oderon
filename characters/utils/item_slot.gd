extends RigidBody2D

var slot = "slot"
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_label()
func update_label():
	label.text = slot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
