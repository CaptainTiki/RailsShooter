extends Node3D
class_name DockingController

signal docking_complete

@export var player_root : PlayerRoot

var docking_position : Vector3
var swap_distance : float = 0.1

func _physics_process(delta: float) -> void:
	if player_root.move_mode == PlayerRoot._mode.ON_RAIL:
		if (global_position - docking_position).length() <= swap_distance:
			docking_complete.emit()
		global_position = global_position.move_toward(docking_position, delta * player_root.current_speed)
