extends Node3D
class_name RailController

signal path_ended

@export var camera : FollowCamera
@export var ship_root : ShipRoot
@export var stats : ShipStats
@export var player_root : PlayerRoot
@export var attitude_controller : AttitudeController

func _ready() -> void:
	disable_rail_travel()

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

func disable_rail_travel()-> void:
	set_physics_process(false)
	set_process(false)

func enable_rail_travel()-> void:
	set_physics_process(true)
	set_process(true)
