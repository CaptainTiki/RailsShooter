extends Node

@export_category("Enumerations")
enum GameState {PAUSED, MENUS, IN_RUN, LOADING}
enum Rarity {NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
enum DamageType {GENERAL, KINETIC, ENERGY, HEAT, EXPLOSIVE, CORROSIVE}

@export_category("Difficulty Settings")
var aim_assist_strength : float = 0.5

@export_category("User Settings")
var invert_y : float = -1

func _input(event: InputEvent) -> void:
	if event.is_action_released("invert_y"):
		invert_y *= -1
