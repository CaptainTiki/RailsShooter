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
var pending_rail_dock: RailDockTrigger = null
var current_speed : float = 8 #8
var direction : int = 1 #direction of travel - set by docking triggers
var rail_transition_in_progress: bool = false
#func _physics_process(delta: float) -> void:
	#print("location: ", global_position)
	#pass

func _ready() -> void:
	docking_controller.docking_complete.connect(_on_rail_docking_complete)

func brake_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, stats.brake_speed, 2 * stats.acceleration * delta)
	camera.set_zoom_in(true)

func boost_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, stats.boost_speed, 2 * stats.acceleration * delta)
	camera.set_zoom_out(true)

func enter_rail_via_trigger(trigger: RailDockTrigger) -> void:
	print("PlayerRoot.enter_rail_via_trigger from mode=", move_mode, " trigger=", trigger.name)
	if move_mode != MoveMode.FREE_FLIGHT: #wont enter these from any other method
		return
	
	pending_rail_dock = trigger
	# Ask the room manager for a docking point near this room's rail
	var dock_pos: Vector3 = GameManager.current_level.room_manager.get_room_path_start(trigger.parent_room)
	docking_controller.docking_position = dock_pos
	set_move_mode(MoveMode.DOCKING)
	rail_transition_in_progress = false

func exit_rail_via_trigger(_trigger: RailDockTrigger) -> void:
	print("PlayerRoot.exit_rail_via_trigger from mode=", move_mode)
	var old_transform := global_transform
	var parent := get_parent()
	set_move_mode(MoveMode.FREE_FLIGHT)
	if parent:
		parent.remove_child(self)
	GameManager.current_level.add_child(self)
	global_transform = old_transform
	rail_transition_in_progress = false

func _on_rail_docking_complete() -> void:
	print("PlayerRoot._on_rail_docking_complete at position=", global_position)
	if pending_rail_dock == null:
		return

	var dock_trigger := pending_rail_dock
	pending_rail_dock = null

	var old_transform := global_transform

	var rail_room: Room = dock_trigger.parent_room
	var path: Path3D = rail_room.rail_path

	if get_parent():
		get_parent().remove_child(self)
	path.add_child(self)

	global_transform = old_transform

	var length := path.curve.get_baked_length()
	var ratio := dock_trigger.target_progress_percent

	# if we ever decide to store 0–1 instead of 0–100, this keeps it safe
	if ratio > 1.0:
		ratio /= 100.0

	progress = length * ratio

	set_move_mode(MoveMode.ON_RAIL)



func un_parent() -> void:
	if get_parent():
		get_parent().remove_child(self)

func set_move_mode(_m : MoveMode)-> void:
	print("set_move_mode: ", move_mode, " -> ", _m)
	move_mode = _m
	MovementModeChanged.emit(move_mode)
	
	match move_mode:
		MoveMode.ON_RAIL:
			rail_controller.set_active(true)
			attitude_controller.enable_attitude_controller(true)
			docking_controller.disable_docking()
			free_flight_controller.set_active(false)
		MoveMode.FREE_FLIGHT:
			print("set to freeflight mode in player_root")
			rail_controller.set_active(false)
			attitude_controller.enable_attitude_controller(true)
			docking_controller.disable_docking()
			free_flight_controller.set_active(true)
		MoveMode.DOCKING:
			rail_controller.set_active(false)
			attitude_controller.enable_attitude_controller(true) #true unless we're using a docking port - have to revisit
			docking_controller.enable_docking()
			free_flight_controller.set_active(false)
		MoveMode.MOVE_TO_PATH: #this is for backwards copat - will be depricated soon
			rail_controller.set_active(false)
			attitude_controller.enable_attitude_controller(true) #true unless we're using a docking port - have to revisit
			docking_controller.enable_docking()
			free_flight_controller.set_active(false)
