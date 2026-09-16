extends ProgressBar

@export var energy = "life"

@onready var character = get_parent()
@onready var fill_style : StyleBoxFlat = get("theme_override_styles/fill").duplicate()

func _ready():
	set("theme_override_styles/fill", fill_style)
	max_value = character.energies[energy][1]

func _process(delta):
	max_value = character.energies[energy][1]
	value = character.energies[energy][0]

	var percentage = value / max_value

	fill_style.bg_color = Color(
		1.0 - percentage,
		percentage,
		0.0
	)
