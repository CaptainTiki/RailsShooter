extends Area3D

var attracted_objects : Array[Area3D]

var magnet_strength : float = 18.0

func _physics_process(delta: float) -> void:
	for area in attracted_objects:
		attract(area, delta)

func attract(area: Area3D, delta: float) -> void:
	area.global_position = area.global_position.move_toward(global_position, magnet_strength * delta)
	
func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("pickup"):
		attracted_objects.append(area)


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("pickup"):
		if attracted_objects.has(area):
			attracted_objects.erase(area)
