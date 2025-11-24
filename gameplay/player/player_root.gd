extends PathFollow3D
class_name PlayerRoot

enum _mode {ON_RAIL, MOVE_TO_PATH, FREE_FLIGHT}

@export var camera : FollowCamera
@onready var ship_root: ShipRoot = $Ship_Root

signal path_ended
signal on_new_path

var parent_level : Level
var move_mode : _mode = _mode.ON_RAIL

var acceleration : float = 6.5
var travel_speed : float = 14.0
var brake_speed : float = 6.0
var boost_speed : float = 24.0
var current_speed : float = 8

var next_path_start : Vector3
var swap_distance : float = 0.5

func _physics_process(delta: float) -> void:
	if move_mode == _mode.ON_RAIL:
		var parent = get_parent()
		if parent is Path3D:
			if progress >= parent.curve.get_baked_length():
				path_ended.emit()
		current_speed = move_toward(current_speed, travel_speed, acceleration * delta)	
		progress += delta * current_speed
	elif move_mode == _mode.FREE_FLIGHT:
		pass
	elif move_mode == _mode.MOVE_TO_PATH:
		if (global_position - next_path_start).length() <= swap_distance:
			on_new_path.emit()
		global_position = global_position.move_toward(next_path_start, delta * current_speed)

func brake_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, brake_speed, 2 * acceleration * delta)
	camera.set_zoom_in(true)

func boost_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, boost_speed, 2 * acceleration * delta)
	camera.set_zoom_out(true)

func set_mode(_m : _mode)-> void:
	move_mode = _m
