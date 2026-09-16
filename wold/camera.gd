extends Camera2D

@onready var target  = $"../camera_target"
var zoom_speed = 0.1
var ZoomSpd = Vector2(0.1,0.1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("roll_up"):
		zoom += ZoomSpd
	if Input.is_action_just_released("roll_down"):
		zoom -= ZoomSpd
	global_position = lerp(global_position,target.global_position,0.3)
