extends Node3D
class_name PlayerInput

signal roll_right
signal roll_left

var gamepad = false
var mouse_pos : Vector2
var input_box_size : Vector2
var input_half_extents : Vector2
var input_center : Vector2
var bank_dir : float = 0.0
var bank_left_pressed : bool = false
var bank_right_pressed : bool = false
var virtual_stick : Vector2

var visual_radius : float = 3.0

@export_category("MouseStick Variables")
@export var _input_box_width_prcnt : float = 0.8 #how much of the screen is used for the stick horizontally
@export var _input_box_height_prcnt : float = 0.8 #how much of the screen is used for the stick vertically
@export var deadzone_prcnt : float = 0.1 #percentage of screen dedicated to "center stick"

@onready var bank_timer: Timer = $Bank_Input_Timer

func _ready() -> void:
	_recalc_inputbox()
	pass
	
func _physics_process(_delta: float) -> void:
	if gamepad:
		get_gamepad_input()
	else:
		get_mouse_input()
	
	get_combined_input()
	
	##update visual debug mesh
	position.x = virtual_stick.x * visual_radius
	position.y = virtual_stick.y * visual_radius


func get_combined_input() -> void:
	#this is where inputs that aren't specific live
	bank_dir = 0
	
	if Input.is_action_just_pressed("bank_left"):
		if bank_timer.is_stopped(): #we just pressed the button - and we had pressed earlier
			bank_timer.start()
		else:
			roll_left.emit()

	if Input.is_action_just_pressed("bank_right"):
		if bank_timer.is_stopped():
			bank_timer.start()
		else:
			roll_right.emit()
	
	if Input.is_action_pressed("bank_left"):
		if bank_timer.is_stopped():
			bank_left_pressed = true
			bank_dir += 1
	else:
		bank_left_pressed = false
		
	if Input.is_action_pressed("bank_right"):
		if bank_timer.is_stopped():
			bank_right_pressed = true
			bank_dir -= 1
	else:
		bank_right_pressed = false

func get_mouse_input() -> void:
	mouse_pos = get_viewport().get_mouse_position()
	var min_bounds : Vector2 = input_center - input_half_extents
	var max_bounds : Vector2 = input_center + input_half_extents
	mouse_pos = mouse_pos.clamp(min_bounds, max_bounds)
	var offset : Vector2 = mouse_pos - input_center
	var input_vector : Vector2 = Vector2(offset.x / input_half_extents.x, offset.y / input_half_extents.y)
	
	if input_vector.length() < deadzone_prcnt:
		input_vector = Vector2.ZERO #if we are inside deadzone, remove input
	
	virtual_stick.x = input_vector.x
	virtual_stick.y = input_vector.y * Globals.invert_y

func get_gamepad_input() -> void:
	#don't need deadzone for gamepad inputs
	virtual_stick.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	virtual_stick.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) * Globals.invert_y

func _recalc_inputbox() -> void:
	var viewport_size : Vector2 = get_viewport().size
	input_center = viewport_size * 0.5
	input_box_size.x = viewport_size.x * _input_box_width_prcnt
	input_box_size.y = viewport_size.x * _input_box_height_prcnt
	input_half_extents = input_box_size * 0.5

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
