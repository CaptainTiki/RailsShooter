extends Node3D
class_name Pickup

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _process(delta: float) -> void:
	mesh_instance_3d.rotate(Vector3.UP, 5 * delta)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		print("collided with player")
		free_pickup()

func free_pickup() -> void:
	queue_free()
