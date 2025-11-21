extends Area3D
class_name Mineable

@onready var target_node: ShipTarget = $Target_Node

func _ready() -> void:
	target_node.register()

func _on_area_entered(area: Area3D) -> void:
		if area.is_in_group("bullet"):
			if area is Projectile:
				target_node.unregister()
				queue_free()
