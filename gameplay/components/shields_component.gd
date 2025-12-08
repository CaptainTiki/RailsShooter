extends Node3D
class_name SheildsComponent

signal shield_damaged
signal shield_depleted
signal shield_restored

@export var max_shield : float = 1.0
@export var regen_amount : float = 1.0 #amount per second
@export var regen_delay : float = 1.0
var current_shields : float = 0.0
var delay : float = 0.0

func _ready() -> void:
	current_shields = max_shield

func _process(delta: float) -> void:
	if current_shields < max_shield:
		regen_shield(delta)

##Absorbs damage up to current shield value, returns any leftover damage for armor/HP
func block_damage(amount: float, _type : Globals.DamageType) -> float:
	delay = regen_delay
	if current_shields > 0:
		current_shields -= amount
		if current_shields >= 0:
			shield_damaged.emit()
			return 0.0 #returning no remaining damage - sheilds held
		else:
			shield_depleted.emit()
			var damage_returned = abs(current_shields) #we should be in negative numbers - we over shot the current shields.
			current_shields = 0 #remove any negative numbers
			return damage_returned
	return amount #we didnt have any shields, so return the full amount of damage back
	
##Handles regeneration over time (using delta for frame-rate independence).
func regen_shield(delta: float) -> void:
	delay -= delta
	if delay <= 0:
		current_shields += regen_amount * delta
		current_shields = clamp(current_shields, 0, max_shield)
		if current_shields >= max_shield:
			shield_restored.emit()

##Manage shield health pool
func get_current_shield() -> float:
	return current_shields

##Manage shield health pool
func set_current_shield(value: float) -> void:
	current_shields = value

##Manage shield health pool
func get_max_shield() -> float:
	return max_shield

##Manage shield health pool
func set_max_shield(value: float) -> void:
	max_shield = value

##Controls the delay before regen starts
func get_regen_delay() -> float:
	return regen_delay

##Controls the delay before regen starts
func set_regen_delay(value: float) -> void:
	regen_delay = value

##Shows how fast shields recharge
func get_regen_rate() -> float:
	return regen_amount

##Sets how fast shields recharge
func set_regen_rate(value: float) -> void:
	regen_amount = value
