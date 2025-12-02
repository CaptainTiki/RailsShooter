extends Node3D
class_name FreeFlightController

@export var camera : FollowCamera
@export var ship_root : ShipRoot
@export var stats : ShipStats
@export var player_root : PlayerRoot
@export var attitude_controller : AttitudeController

func _ready() -> void:
	set_active(false)

func _physics_process(delta: float) -> void:
	if player_root.move_mode == PlayerRoot.MoveMode.FREE_FLIGHT:
		player_root.current_speed = move_toward(player_root.current_speed, stats.travel_speed, stats.acceleration * delta)
		player_root.global_position += -player_root.global_basis.z * delta * player_root.current_speed
		#player_root.progress += delta * current_speed
		attitude_controller.set_freeflight_pose(delta)

func brake_ship(delta: float) -> void:
	player_root.current_speed = move_toward(player_root.current_speed, player_root.brake_speed, 2 * player_root.acceleration * delta)
	camera.set_zoom_in(true)

func boost_ship(delta: float) -> void:
	player_root.current_speed = move_toward(player_root.current_speed, player_root.boost_speed, 2 * player_root.acceleration * delta)
	camera.set_zoom_out(true)

func set_active(active : bool)-> void:
	set_physics_process(active)
	set_process(active)
