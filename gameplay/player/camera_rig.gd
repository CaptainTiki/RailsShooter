extends Node3D
class_name CameraRig

@export var target_distance : float = 10.0  # how far away we *want* to be
@export var damping : float = 0.5
@export_range(0.1, 20.0, 0.1) var position_lerp_speed : float = 5.0  # how fast we move toward the desired point
@export var snap_distance : float = 50.0
@export var look_at_target : bool = true   # auto-aim back at the target

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

func spring_to_target(delta: float) -> void:
	var t : Vector3 = target.global_position
	var dir: Vector3 = (global_position - t).normalized()
	var desired_pos : Vector3 = t + dir * desired_distance
	var current = global_transform.origin
	var new : Vector3
	var dist_to_desired = (desired_pos - global_position).length()
	if dist_to_desired < snap_distance:
		var alpha : float = clamp(position_lerp_speed * delta, 0.0, 1.0)
		new = current.lerp(desired_pos, alpha)
	else:
		new = desired_pos

	global_transform.origin = new


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
