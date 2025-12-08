extends Node
class_name ArmorComponent

##armor_amount is a percentage
@export var armor_amount : float = 0.01

func reduce_damage(amount: float, _type : Globals.DamageType) -> float:
	var dmg_reduction : float = amount * armor_amount
	var damage_amount : float = amount - dmg_reduction
	damage_amount = clamp(damage_amount, 0, amount)
	return damage_amount

func get_armor_value() -> float:
	return armor_amount

func add_armor(value: float) -> void:
	armor_amount += value
	clamp(armor_amount, 0, 1)

func remove_armor(value: float) -> void:
	armor_amount -= value
	clamp(armor_amount, 0, 1)
