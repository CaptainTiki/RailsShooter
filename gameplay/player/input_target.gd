extends Node3D
class_name InputTarget

var gamepad = false
var mouse_pos : Vector2
var input_box_size : Vector2
var input_half_extents : Vector2
var input_center : Vector2

var virtual_stick : Vector2

@export_category("MouseStick Variables")
@export var _input_box_width_prcnt : float = 0.8 #how much of the screen is used for the stick horizontally
@export var _input_box_height_prcnt : float = 0.8 #how much of the screen is used for the stick vertically
@export var deadzone_prcnt : float = 0.1 #percentage of screen dedicated to "center stick"

func _ready() -> void:
	_recalc_inputbox()
	pass
	
func _physics_process(_delta: float) -> void:
	if gamepad:
		get_gamepad_input()
	else:
		get_mouse_input()
	
	#update visual debug mesh
	position.x = virtual_stick.x
	position.y = virtual_stick.y

func get_mouse_input() -> void:
	mouse_pos = get_viewport().get_mouse_position()
	mouse_pos.clamp(-input_half_extents, input_half_extents)
	var offset : Vector2 = Vector2(mouse_pos.x - input_center.x, mouse_pos.y - input_center.y)
	var input_vector : Vector2
	input_vector.x = offset.x / input_half_extents.x
	input_vector.y = offset.y / input_half_extents.y
	virtual_stick.x = -input_vector.x
	virtual_stick.y = input_vector.y * Globals.invert_y
	
	if input_vector.length() > deadzone_prcnt * input_box_size.length():
		virtual_stick = Vector2.ZERO #if we are inside deadzone, remove input
	
	print("virtual_stick: ", virtual_stick)

func get_gamepad_input() -> void:
	#don't need deadzone for gamepad inputs
	virtual_stick.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	virtual_stick.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) * Globals.invert_y

func _recalc_inputbox() -> void:
	var viewport_size : Vector2 = get_viewport().size
	input_box_size.x = viewport_size.x * _input_box_width_prcnt
	input_box_size.y = viewport_size.y * _input_box_height_prcnt
	input_center = input_box_size / 2
	input_half_extents.x = input_box_size.x / 2
	input_half_extents.y = input_box_size.y / 2

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
