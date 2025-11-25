extends Node3D
class_name FreeFlightController


func disable_free_travel()-> void:
	set_physics_process(false)
	set_process(false)

func enable_free_travel()-> void:
	set_physics_process(true)
	set_process(true)
