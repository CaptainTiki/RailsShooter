extends Node3D
class_name FreeFlightController

signal end_arena_room(trigger : RoomExitTrigger)

@export var camera : FollowCamera
@export var ship_root : ShipRoot
@export var stats : ShipStats
@export var player_root : PlayerRoot
@export var attitude_controller : AttitudeController

func _ready() -> void:
	disable_free_travel()

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

func disable_free_travel()-> void:
	set_physics_process(false)
	set_process(false)

func enable_free_travel()-> void:
	set_physics_process(true)
	set_process(true)

func ArenaRoomEnded(trigger : RoomExitTrigger) -> void:
	end_arena_room.emit(trigger)
