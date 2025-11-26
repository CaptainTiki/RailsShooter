extends Node3D
class_name AttitudeController

@export var ship_root : ShipRoot
@export var player_input : PlayerInput

@export var rail_controller : RailController

@export_category("Ship Variables")
@export var move_speed : float = 12
@export var rotation_speed : float = 7
@export var roll_speed : float = 6
@export var max_pitch_angle : float = 0.3
@export var max_yaw_angle : float = 0.3
@export var max_roll_angle : float = 3

var velocity : Vector3 = Vector3.ZERO

func set_rail_pose(delta : float)-> void:
	velocity = Vector3(player_input.virtual_stick.x, player_input.virtual_stick.y, 0)
	ship_root.position += velocity * move_speed * delta
	#TODO: clamp ship position based on viewport size
	ship_root.position.x = clamp(ship_root.position.x, -16, 16)
	ship_root.position.y = clamp(ship_root.position.y, -10, 4)
	
	#TODO: hook up faster yaw while banking (roll)
	var target_rot_x = player_input.virtual_stick.y * max_pitch_angle
	var target_rot_y = -player_input.virtual_stick.x * max_yaw_angle
	
	if not ship_root.is_rolling: #dont rotate roll - if we're doing the roll tween
		ship_root.rotation.z = lerp(ship_root.rotation.z, player_input.bank_dir * max_roll_angle, roll_speed * delta)
	
	ship_root.rotation = ship_root.rotation.lerp(Vector3(target_rot_x, target_rot_y,0), rotation_speed * delta)


func set_docking_pose(delta : float)-> void:
	velocity = Vector3(player_input.virtual_stick.x, player_input.virtual_stick.y, 0)
	ship_root.position += velocity * move_speed * delta
	#TODO: clamp ship position based on viewport size
	ship_root.position.x = clamp(ship_root.position.x, -16, 16)
	ship_root.position.y = clamp(ship_root.position.y, -10, 4)
	
	#TODO: hook up faster yaw while banking (roll)
	var target_rot_x = player_input.virtual_stick.y * max_pitch_angle
	var target_rot_y = -player_input.virtual_stick.x * max_yaw_angle
	
	if not ship_root.is_rolling: #dont rotate roll - if we're doing the roll tween
		ship_root.rotation.z = lerp(ship_root.rotation.z, player_input.bank_dir * max_roll_angle, roll_speed * delta)
	
	ship_root.rotation = ship_root.rotation.lerp(Vector3(target_rot_x, target_rot_y,0), rotation_speed * delta)

func set_freeflight_pose()-> void:
	pass
