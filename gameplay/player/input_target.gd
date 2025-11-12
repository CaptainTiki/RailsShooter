extends Node3D
class_name InputTarget

var use_mouse = false
var mouse_pos : Vector2

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	position = Vector3.ZERO
	var local_position : Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		local_position.y += 1
	if Input.is_action_pressed("move_down"):
		local_position.y -= 1
	if Input.is_action_pressed("move_left"):
		local_position.x -= 1
	if Input.is_action_pressed("move_right"):
		local_position.x += 1
	
	local_position *= 3
	
	position = local_position
