extends Node3D
class_name AttitudeController

@export var ship_root : ShipRoot
@export var player_root : PlayerRoot
@export var stats : ShipStats
@export var player_input : PlayerInput

@export var rail_controller : RailController

var velocity : Vector3 = Vector3.ZERO
var enable_attitude_control : bool = false

func _ready() -> void:
	enable_attitude_controller(false)

func set_rail_pose(delta : float)-> void:
	velocity = Vector3(player_input.virtual_stick.x, player_input.virtual_stick.y, 0)
	ship_root.position += velocity * stats.lateral_speed * delta
	#TODO: clamp ship position based on viewport size
	ship_root.position.x = clamp(ship_root.position.x, -16, 16)
	ship_root.position.y = clamp(ship_root.position.y, -10, 4)
	
	#TODO: hook up faster yaw while banking (roll)
	var target_rot_x = player_input.virtual_stick.y * stats.max_pitch_angle
	var target_rot_y = -player_input.virtual_stick.x * stats.max_yaw_angle
	
	if not ship_root.is_rolling: #dont rotate roll - if we're doing the roll tween
		ship_root.rotation.z = lerp(ship_root.rotation.z, player_input.bank_dir * stats.max_roll_angle, stats.roll_speed * delta)
	
	ship_root.rotation = ship_root.rotation.lerp(Vector3(target_rot_x, target_rot_y,0), stats.rotation_speed * delta)


func set_docking_pose(delta : float)-> void:
	velocity = Vector3(player_input.virtual_stick.x, player_input.virtual_stick.y, 0)
	ship_root.position += velocity * stats.lateral_speed * delta
	#TODO: clamp ship position based on viewport size
	ship_root.position.x = clamp(ship_root.position.x, -16, 16)
	ship_root.position.y = clamp(ship_root.position.y, -10, 4)
	
	#TODO: hook up faster yaw while banking (roll)
	var target_rot_x = player_input.virtual_stick.y * stats.max_pitch_angle
	var target_rot_y = -player_input.virtual_stick.x * stats.max_yaw_angle
	
	if not ship_root.is_rolling: #dont rotate roll - if we're doing the roll tween
		ship_root.rotation.z = lerp(ship_root.rotation.z, player_input.bank_dir * stats.max_roll_angle, stats.roll_speed * delta)
	
	ship_root.rotation = ship_root.rotation.lerp(Vector3(target_rot_x, target_rot_y,0), stats.rotation_speed * delta)

func set_freeflight_pose(delta: float)-> void:
	#do pitch and yaw
	player_root.rotation += Vector3(player_input.virtual_stick.y, -player_input.virtual_stick.x, 0) * delta
	
	#do our knife edge
	if not ship_root.is_rolling: #dont rotate roll - if we're doing the roll tween
		ship_root.rotation.z = lerp(ship_root.rotation.z, player_input.bank_dir * stats.max_roll_angle, stats.roll_speed * delta)

func enable_attitude_controller(enable : bool)-> void:
	enable_attitude_control = enable
