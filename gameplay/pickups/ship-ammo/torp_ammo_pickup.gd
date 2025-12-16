extends Pickup
class_name TorpAmmoPickup

var num_ammo : int = 1

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		if area is ShipRoot:
			var _weapon = area.get_node("Weapon") as Weapon
			#weapon.add_torp_ammo(num_ammo)
		free_pickup()
