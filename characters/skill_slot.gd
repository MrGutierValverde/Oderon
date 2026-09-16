# SkillSlot.gd
extends Control
@onready var character = $"../../.."
var skill = null

func set_skill(new_skill):
	skill = new_skill
	update_ui()

func use_skill(owner):
	if skill:
		character.select_skill(skill)

func update_ui():
	if skill:
		if skill.icon:
			$Icon.texture = skill.icon
	else:
		$Icon.texture = null
