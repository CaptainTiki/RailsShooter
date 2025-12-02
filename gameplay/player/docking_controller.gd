extends Node3D
class_name DockingController

signal docking_complete

@export var player_root : PlayerRoot
@export var stats : ShipStats

var docking_position : Vector3
var swap_distance : float = 0.1
var cinematic_mode : bool = false

func _ready() -> void:
	disable_docking()

func _physics_process(delta: float) -> void:
	if cinematic_mode: #if we're docking to a docking port - use docking speed
		if player_root.move_mode == PlayerRoot.MoveMode.MOVE_TO_PATH or player_root.move_mode == PlayerRoot.MoveMode.DOCKING:
			if (player_root.global_position - docking_position).length() <= swap_distance:
				docking_complete.emit()
			player_root.global_position = player_root.global_position.move_toward(docking_position, delta * stats.docking_speed)
	else: #if we're transitioning to a new rail - keep current speed consistent
		if player_root.move_mode == PlayerRoot.MoveMode.MOVE_TO_PATH or player_root.move_mode == PlayerRoot.MoveMode.DOCKING:
			if (player_root.global_position - docking_position).length() <= swap_distance:
				docking_complete.emit()
			player_root.global_position = player_root.global_position.move_toward(docking_position, delta * player_root.current_speed)

func disable_docking()-> void:
	set_physics_process(false)
	set_process(false)

func enable_docking()-> void:
	set_physics_process(true)
	set_process(true)
