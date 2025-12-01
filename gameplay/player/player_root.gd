extends PathFollow3D
class_name PlayerRoot

signal MovementModeChanged(move_mode : MoveMode)

enum MoveMode {ON_RAIL, MOVE_TO_PATH, FREE_FLIGHT, DOCKING}

@export var camera : FollowCamera
@onready var stats: ShipStats = %ShipStats
@onready var ship_root: ShipRoot = $Ship_Root
@onready var rail_controller: RailController = $Rail_Controller
@onready var free_flight_controller: FreeFlightController = $FreeFlight_Controller
@onready var docking_controller: DockingController = $Docking_Controller
@onready var attitude_controller: AttitudeController = $Attitude_Controller

var parent_level : Level
var move_mode : MoveMode = MoveMode.ON_RAIL

var current_speed : float = 8 #8

#func _physics_process(delta: float) -> void:
	#print("location: ", global_position)
	#pass

func brake_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, stats.brake_speed, 2 * stats.acceleration * delta)
	camera.set_zoom_in(true)

func boost_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, stats.boost_speed, 2 * stats.acceleration * delta)
	camera.set_zoom_out(true)

func un_parent() -> void:
	if get_parent():
		get_parent().remove_child(self)

func set_mode(_m : MoveMode)-> void:
	move_mode = _m
	MovementModeChanged.emit(move_mode)
	
	match move_mode:
		MoveMode.ON_RAIL:
			rail_controller.enable_rail_travel()
			attitude_controller.enable_attitude_controller(true)
			docking_controller.disable_docking()
			free_flight_controller.disable_free_travel()
		MoveMode.FREE_FLIGHT:
			print("set to freeflight mode in player_root")
			rail_controller.disable_rail_travel()
			attitude_controller.enable_attitude_controller(true)
			docking_controller.disable_docking()
			free_flight_controller.enable_free_travel()
		MoveMode.DOCKING:
			rail_controller.disable_rail_travel()
			attitude_controller.enable_attitude_controller(true) #true unless we're using a docking port - have to revisit
			docking_controller.enable_docking()
			free_flight_controller.disable_free_travel()
		MoveMode.MOVE_TO_PATH: #this is for backwards copat - will be depricated soon
			rail_controller.disable_rail_travel()
			attitude_controller.enable_attitude_controller(true) #true unless we're using a docking port - have to revisit
			docking_controller.enable_docking()
			free_flight_controller.disable_free_travel()
