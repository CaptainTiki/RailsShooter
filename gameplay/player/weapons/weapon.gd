extends Node3D
class_name Weapon

enum Belt {PRIMARY, SECONDARY}

signal weapon_fired

@export var display_name: String = "Default Weapon Name"
@export var icon: Texture2D = preload("res://icon.png")

@export var ammo_type : Globals.AmmoType = Globals.AmmoType.ENERGY
@export var ammo_cost_per_shot : float = 1
@export var weapon_belt : Belt = Belt.PRIMARY

@onready var hub: Weaponhub = get_parent() as Weaponhub

#intended to be overridden
func fire_pressed() -> void:
	if not can_fire():
		return

#intended to be overridden
func fire_released() -> void:
	pass

#intended to be overridden
func can_fire() -> bool:
	return hub.has_ammo(ammo_type, ammo_cost_per_shot)

func try_consume_ammo() -> bool:
	if not hub.has_ammo(ammo_type, ammo_cost_per_shot):
		return false
	hub.consume_ammo(ammo_type, ammo_cost_per_shot)
	return true
