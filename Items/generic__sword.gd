extends Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slot = "head"
	modifiers = {
		"attack_speed"={
			"base_added":0,
			"added_multiplier":0,
			"global_multiplier":1.1
		},
		"melee_attack_damage"={
			"base_added":5,
			"added_multiplier":0,
			"global_multiplier":1
		},
		"physical_precision"={
			"base_added":10,
			"added_multiplier":0,
			"global_multiplier":1
		},
	}
func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("left_click"):
			initialPos = global_position
			offset = get_global_mouse_position()-global_position
			Global.is_dragging = true
		if Input.is_action_pressed("left_click"):
			global_position = get_global_mouse_position()-offset
		elif Input.is_action_just_released("left_click"):
			Global.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_droppeable:
				tween.tween_property(self,"global_position",body_ref.global_position,0.2).set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(self,"global_position",initialPos,0.2).set_ease(Tween.EASE_OUT)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Droppeable") and body.slot == slot:
		is_inside_droppeable = true
		#body.modulate = Color(Color.BLUE,1)
		body_ref = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Droppeable"):
		is_inside_droppeable = false
		#body.modulate = Color(Color.BLUE,0.7)


func _on_area_2d_mouse_entered() -> void:
	if not Global.is_dragging:
		draggable = true
		scale = Vector2(1.05,1.05)


func _on_area_2d_mouse_exited() -> void:
	if not Global.is_dragging:
		draggable = false
		scale = Vector2(1,1)
