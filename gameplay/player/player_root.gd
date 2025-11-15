extends PathFollow3D
class_name PlayerRoot

@export var camera : FollowCamera

var acceleration : float = 6
var travel_speed : float = 18.0
var brake_speed : float = 9.0
var boost_speed : float = 24.0
var current_speed : float = 8

func _physics_process(delta: float) -> void:
	current_speed = move_toward(current_speed, travel_speed, acceleration * delta)
	
	if Input.is_action_pressed("brake"):
		_brake_ship(delta)
	if Input.is_action_pressed("boost"):
		_boost_ship(delta)
	
	if Input.is_action_just_released("brake"):
		camera.set_zoom_in(false)
	if Input.is_action_just_released("boost"):
		camera.set_zoom_out(false)
	
	progress += delta * current_speed

func _brake_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, brake_speed, 2 * acceleration * delta)
	camera.set_zoom_in(true)

func _boost_ship(delta: float) -> void:
	current_speed = move_toward(current_speed, boost_speed, 2 * acceleration * delta)
	camera.set_zoom_out(true)
