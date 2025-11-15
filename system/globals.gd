extends Node

enum Rarity {NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

var invert_y : float = -1

func _input(event: InputEvent) -> void:
	if event.is_action_released("invert_y"):
		invert_y *= -1
