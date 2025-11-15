extends Node3D

@export var input_target : InputTarget
@export var camera : FollowCamera

var deadzone : float = 0.05

var thrust_accel : float = 30
var rotation_speed : float = 6
var velocity : Vector3 = Vector3.ZERO
var roll_tween : Tween
var drag : float = 20
var max_pitch_rotation : float = 1
var max_bank_rotation : float = 1


func _process(delta: float) -> void:

	if Input.is_action_just_pressed("dodge_roll"):
		dodge_roll()
	
	var input_dir = Vector3(input_target.position.x, input_target.position.y, 0)
	velocity += input_dir * thrust_accel * delta
	velocity = velocity.move_toward(Vector3.ZERO, drag * delta)
	
	position += velocity * delta
	position.x = clamp(position.x, -8, 8)
	position.y = clamp(position.y, -6, 2.5)
	
	var target_rot_x = input_target.position.y * max_pitch_rotation
	var target_rot_z = -input_target.position.x * max_bank_rotation
	var target_rot_y = target_rot_z
	
	rotation = rotation.lerp(Vector3(target_rot_x, target_rot_y, rotation.z), rotation_speed * delta)
	
	camera.set_pos(position)

func dodge_roll() -> void:
	#TODO: set invul flags here
	var rotate_target = rotation.z + (2 * PI)
	roll_tween = create_tween()
	roll_tween.tween_property(self, "rotation:z", rotate_target, 0.5)
	roll_tween.connect("finished", finish_roll)
	roll_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func finish_roll() -> void:
	#TODO: unset invul flags here
	#TODO: set roll cooldown
	rotation.z = 0
