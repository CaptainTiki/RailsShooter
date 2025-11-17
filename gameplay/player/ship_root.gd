extends Node3D

@export_category("Node Links")
@export var input_target : InputTarget
@export var camera : FollowCamera

@export_category("Movement Variables")
@export var move_speed : float = 10
@export var rotation_speed : float = 6
@export var max_pitch_angle : float = 0.3
@export var max_yaw_angle : float = 0.3
@export var max_roll_angle : float = 0.5
@export var barrel_roll_duration : float = 1.0 #in seconds
@export var num_barrel_rolls : int = 1
@export var barrel_roll_cooldown = 3.0

var velocity : Vector3 = Vector3.ZERO

var roll_tween : Tween #used for barrel rolls

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("dodge_roll"):
		dodge_roll()
	
	velocity = Vector3(input_target.virtual_stick.x, input_target.virtual_stick.y, 0)
	position += velocity * delta
	position.x = clamp(position.x, -8, 8)
	position.y = clamp(position.y, -6, 2.5)
	
	#TODO: hook up faster yaw while banking (roll)
	var target_rot_x = input_target.position.y * max_pitch_angle
	var target_rot_y = input_target.position.x * max_yaw_angle
	
	rotation = rotation.lerp(Vector3(target_rot_x, target_rot_y, 0), rotation_speed * delta)
	
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
