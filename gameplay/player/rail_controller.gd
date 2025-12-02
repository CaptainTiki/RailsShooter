extends Node3D
class_name RailController

signal path_ended

@export var camera : FollowCamera
@export var ship_root : ShipRoot
@export var stats : ShipStats
@export var player_root : PlayerRoot
@export var attitude_controller : AttitudeController

func _ready() -> void:
	set_active(false)

func _physics_process(delta: float) -> void:
	if player_root.move_mode == PlayerRoot.MoveMode.ON_RAIL:
		player_root.current_speed = move_toward(player_root.current_speed, stats.travel_speed, stats.acceleration * delta)	
		player_root.progress += delta * player_root.current_speed
		attitude_controller.set_rail_pose(delta)
		if player_root.progress >= player_root.get_parent().curve.get_baked_length():
			path_ended.emit()

func brake_ship(delta: float) -> void:
	player_root.current_speed = move_toward(player_root.current_speed, player_root.brake_speed, 2 * player_root.acceleration * delta)
	camera.set_zoom_in(true)

func boost_ship(delta: float) -> void:
	player_root.current_speed = move_toward(player_root.current_speed, player_root.boost_speed, 2 * player_root.acceleration * delta)
	camera.set_zoom_out(true)

func set_active(active : bool)-> void:
	set_physics_process(active)
	set_process(active)
