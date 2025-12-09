extends PathFollow3D
class_name PlayerRoot

signal PlayerDied
signal MovementModeChanged(move_mode : MoveMode)

enum MoveMode {NONE, ON_RAIL, MOVE_TO_PATH, FREE_FLIGHT, DOCKING}

@export var camera : FollowCamera
@onready var stats: ShipStats = %ShipStats
@onready var ship_root: ShipRoot = $Ship_Rotation_Handler/Ship_Root
@onready var ship_handler: Node3D = $Ship_Rotation_Handler
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

func _ready() -> void:
	rotation_mode = PathFollow3D.RotationMode.ROTATION_NONE
	tilt_enabled = false
	docking_controller.docking_complete.connect(_on_rail_docking_complete)
	ship_root.health_component.died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	_align_ship_to_rail(delta)

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
	if pending_rail_dock == null:
		return

	print("PlayerRoot._on_rail_docking_complete at position=", global_position, ", gate: ", pending_rail_dock)
	
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
		MoveMode.NONE:
			#we're dead - or cinematic - turn off input
			rail_controller.set_active(false)
			attitude_controller.enable_attitude_controller(false)
			docking_controller.disable_docking()
			free_flight_controller.set_active(false)
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

func _on_player_died() -> void:
	set_move_mode(MoveMode.NONE) #disable input
	PlayerDied.emit()

func _align_ship_to_rail(delta : float) -> void:
	# Only care when we're on the rail or docking toward it
	if move_mode != MoveMode.ON_RAIL and move_mode != MoveMode.DOCKING:
		return

	var path : Path3D = get_parent() as Path3D
	if path == null or path.curve == null:
		return

	var curve: Curve3D = path.curve
	var length : float = curve.get_baked_length()
	if length <= 0.0:
		return

	# PathFollow3D.progress is distance along the curve in 3D units
	var d0 : float = clamp(progress, 0.0, length)
	var d1 : float = clamp(progress + stats.lead_ammount, 0.0, length)  # 0.5 units ahead, tweak to taste

	var p0 : Vector3 = curve.sample_baked(d0)
	var p1 : Vector3 = curve.sample_baked(d1)

	var rail_forward_local : Vector3 = (p1 - p0).normalized()
	if rail_forward_local == Vector3.ZERO:
		return

	# Convert to global direction using the Path3D's basis
	var rail_forward_global : Vector3 = (path.global_transform.basis * rail_forward_local).normalized()

	# Build a target basis facing along the rail, using global up
	var target_basis : Basis = Basis.looking_at(rail_forward_global, Vector3.UP)

	# Strip roll so PlayerRoot only carries yaw + pitch
	var euler : Vector3 = target_basis.get_euler()
	euler.z = 0.0
	target_basis = Basis.from_euler(euler)

	# Smoothly rotate PlayerRoot toward that target
	var current_basis : Basis = ship_handler.global_transform.basis
	var t : float = clamp(stats.rail_align_speed * delta, 0.0, 1.0)
	var new_basis : Basis = current_basis.slerp(target_basis, t)

	var xform : Transform3D = ship_handler.global_transform
	xform.basis = new_basis.orthonormalized()
	ship_handler.global_transform = xform
	
	var yaw : float = ship_handler.global_transform.basis.get_euler().y
	print(rad_to_deg(yaw))
