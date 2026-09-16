# SkillBar.gd
extends Control

@onready var slots = $".".get_children()
@onready var skills_node: Node = $"../../Skills"

func _ready():
	pass

func assign_skill_to_slot(slot_index: int, skill_name: String):
	var skill = skills_node.get_node(skill_name)
	slots[slot_index].set_skill(skill)
