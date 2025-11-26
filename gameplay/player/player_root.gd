extends PathFollow3D
class_name PlayerRoot

enum _mode {ON_RAIL, MOVE_TO_PATH, FREE_FLIGHT, DOCKING}

@export var camera : FollowCamera
@onready var ship_root: ShipRoot = $Ship_Root
@onready var rail_controller: RailController = $Rail_Controller
@onready var free_flight_controller: FreeFlightController = $FreeFlight_Controller
@onready var docking_controller: DockingController = $Docking_Controller

var parent_level : Level
var move_mode : _mode = _mode.ON_RAIL

var acceleration : float = 6.5 #6.5
var travel_speed : float = 14.0 #14.0
var brake_speed : float = 6.0
var boost_speed : float = 24.0 #24.0
var current_speed : float = 8 #8

func brake_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, brake_speed, 2 * acceleration * delta)
	camera.set_zoom_in(true)

func boost_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, boost_speed, 2 * acceleration * delta)
	camera.set_zoom_out(true)

func set_mode(_m : _mode)-> void:
	move_mode = _m
		
