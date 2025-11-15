extends Node3D
class_name InputTarget

var gamepad = false
var mouse_pos : Vector2
var viewport_size : Vector2

func _ready() -> void:

	mouse_pos = get_viewport().get_mouse_position()
	viewport_size = get_viewport().size
	pass
	
func _physics_process(_delta: float) -> void:
	if gamepad:
		get_gamepad_input()
	else:
		get_mouse_input()
	pass

func get_mouse_input() -> void:
	mouse_pos = get_viewport().get_mouse_position()
	var input_vector : Vector2 = mouse_pos / viewport_size
	position.x = input_vector.x - 0.5
	position.y = (input_vector.y - 0.5) * Globals.invert_y

func get_gamepad_input() -> void:
	position = Vector3.ZERO
	position.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	position.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) * Globals.invert_y

func _input(event: InputEvent) -> void:
	#check if we're using mouse and keyboard
	if event is InputEventMouseMotion:
		gamepad = false
	if event is InputEventMouseButton:
		gamepad = false
	if event is InputEventKey:
		gamepad = false
	
	#or are we using the gamepad
	if event is InputEventJoypadMotion:
		gamepad = true
	if event is InputEventJoypadButton:
		gamepad = true
