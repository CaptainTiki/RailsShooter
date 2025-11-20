extends Area3D
class_name ShipRoot

@export_category("Node Links")
@export var input_target : InputTarget
@export var camera : FollowCamera

@export_category("Movement Variables")
@export var move_speed : float = 12
@export var rotation_speed : float = 7
@export var roll_speed : float = 6
@export var max_pitch_angle : float = 0.3
@export var max_yaw_angle : float = 0.3
@export var max_roll_angle : float = 3
@export var barrel_roll_duration : float = 1.0 #in seconds
@export var num_barrel_rolls : int = 4
@export var barrel_roll_cooldown = 3.0

@onready var roll_cooldown_timer: Timer = $RollCooldown
@onready var weapon: Weapon = $Weapon

var velocity : Vector3 = Vector3.ZERO

var roll_tween : Tween #used for barrel rolls
var is_rolling : bool = false

func _ready() -> void:
	input_target.roll_left.connect(roll_left)
	input_target.roll_right.connect(roll_right)

func _process(delta: float) -> void:
	if Input.is_action_pressed("fire_primary"):
		weapon.fire_guns()
	if Input.is_action_pressed("fire_secondary"):
		weapon.fire_torp()

func _physics_process(delta: float) -> void:
	
	velocity = Vector3(input_target.virtual_stick.x, input_target.virtual_stick.y, 0)
	position += velocity * move_speed * delta
	position.x = clamp(position.x, -8, 8)
	position.y = clamp(position.y, -6, 2.5)
	
	#TODO: hook up faster yaw while banking (roll)
	var target_rot_x = input_target.virtual_stick.y * max_pitch_angle
	var target_rot_y = -input_target.virtual_stick.x * max_yaw_angle
	
	if not is_rolling: #dont rotate roll - if we're doing the roll tween
		rotation.z = lerp(rotation.z, input_target.bank_dir * max_roll_angle, roll_speed * delta)
	
	rotation = rotation.lerp(Vector3(target_rot_x, target_rot_y,0), rotation_speed * delta)

func roll_left() -> void:
	if roll_cooldown_timer.is_stopped():
		#TODO: set invul flags here
		is_rolling = true
		var rotate_target = (rotation.z + (num_barrel_rolls * PI)) * 1
		roll_tween = create_tween()
		roll_tween.tween_property(self, "rotation:z", rotate_target, barrel_roll_duration)
		roll_tween.connect("finished", finish_roll)
		roll_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func roll_right() -> void:
	if roll_cooldown_timer.is_stopped():
		#TODO: set invul flags here
		var rotate_target = (rotation.z + (num_barrel_rolls * PI)) * -1
		roll_tween = create_tween()
		roll_tween.tween_property(self, "rotation:z", rotate_target, barrel_roll_duration)
		roll_tween.connect("finished", finish_roll)
		roll_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func finish_roll() -> void:
	#TODO: unset invul flags here
	roll_cooldown_timer.start()
	is_rolling = false
	rotation.z = 0
