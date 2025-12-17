extends Node3D
class_name CameraRig

@export var follow_height: float = 1.0
@export var follow_side: float = 0.0

# Lateral/vertical spring tuning 
@export var lat_min_speed: float = 0.40
@export var lat_max_speed: float = 20.0
@export var lat_catchup_dist: float = 6.0

@export var vert_min_speed: float = 0.40
@export var vert_max_speed: float = 20.0
@export var vert_catchup_dist: float = 6.0

# Distance spring tuning 
@export var dist_min_speed: float = 1.0
@export var dist_max_speed: float = 60.0
@export var dist_catchup_dist: float = 12.0

# Optional safety recovery for extreme teleports/spawns
@export var hard_snap_distance: float = 80.0

@export var target_distance : float = 10.0  # how far away we *want* to be
@export var damping : float = 0.5
@export_range(0.1, 20.0, 0.1) var position_lerp_speed : float = 5.0  # how fast we move toward the desired point
@export var catchup_distance : float = 20.0
@export var look_at_target : bool = true   # auto-aim back at the target
@export var max_follow_speed : float = 20
@export var min_follow_speed : float = 0.1
@export var zoom_in_dist : float = 6
@export var zoom_out_dist : float = 9
@export var zoom_lerp_speed : float = 2

@onready var camera: Camera3D = $Camera3D

var target : Node3D 
var desired_distance : float = 10
var zoom_in : bool = false
var zoom_out : bool = false

func _ready() -> void:
	GameManager.gamestate_changed.connect(_change_target)

func _physics_process(delta: float) -> void:
	if !target:
		return
	
	handle_distance(delta)
	spring_to_target(delta)
	look_at_tgt(delta)

func handle_distance(delta: float) -> void:
	if zoom_in:
		desired_distance = lerp(desired_distance, zoom_in_dist, zoom_lerp_speed * delta)
	elif zoom_out:
		desired_distance = lerp(desired_distance, zoom_out_dist, zoom_lerp_speed * delta)
	else:
		desired_distance = lerp(desired_distance, target_distance, zoom_lerp_speed * delta)

func _alpha_for_axis(error_mag: float, min_speed: float, max_speed: float, catchup_dist: float, delta: float) -> float:
	var t : float = clamp(error_mag / max(catchup_dist, 0.001), 0.0, 1.0)
	# Make it gentler near zero but still punchy when far
	t = t * t
	var speed : float = lerp(min_speed, max_speed, t)
	return 1.0 - exp(-speed * delta)

func spring_to_target(delta: float) -> void:
	var t: Vector3 = target.global_position
	var b: Basis = target.global_transform.basis

	var behind: Vector3 = b.z.normalized() * desired_distance
	var up: Vector3 = b.y.normalized() * follow_height
	var side: Vector3 = b.x.normalized() * follow_side
	var desired_pos: Vector3 = t + behind + up + side

	var current: Vector3 = global_transform.origin
	var world_error: Vector3 = desired_pos - current
	var dist_total := world_error.length()

	if dist_total > hard_snap_distance:
		global_transform.origin = desired_pos
		return

	# Convert error into target-local space so X/Y/Z mean what we want.
	var local_error: Vector3 = b.inverse() * world_error

	var ax := _alpha_for_axis(abs(local_error.x), lat_min_speed,  lat_max_speed,  lat_catchup_dist,  delta)
	var ay := _alpha_for_axis(abs(local_error.y), vert_min_speed, vert_max_speed, vert_catchup_dist, delta)
	var az := _alpha_for_axis(abs(local_error.z), dist_min_speed, dist_max_speed, dist_catchup_dist, delta)

	# Lerp each axis independently in LOCAL space
	var local_step := Vector3(
		lerp(0.0, local_error.x, ax),
		lerp(0.0, local_error.y, ay),
		lerp(0.0, local_error.z, az)
	)

	# Convert step back to world and apply
	global_transform.origin = current + (b * local_step)


func look_at_tgt(_delta: float) -> void:
	if look_at_target:
		look_at(target.global_position)

func _change_target() -> void:
	print("changed target")
	match  GameManager.game_state:
		Globals.GameState.IN_RUN:
			target = GameManager.current_level.player_ship
			global_transform.origin = target.global_position + global_transform.basis.z.normalized() * desired_distance
		Globals.GameState.MENUS:
			target = null
