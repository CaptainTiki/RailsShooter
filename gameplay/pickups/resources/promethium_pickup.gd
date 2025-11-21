extends Pickup
class_name PromethiumPickup

var min_ore : int = 1
var max_ore : int = 3

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		if area is ShipRoot:
			area.add_cargo(0,randi_range(min_ore,max_ore),0,0)
		free_pickup()
