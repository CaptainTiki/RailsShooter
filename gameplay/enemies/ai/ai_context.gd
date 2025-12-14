extends Node3D
class_name AIContext

@onready var state_machine: AIStateMachine = $"../AiStateMachine"

var aim_target : Node3D
var aim_target_velocity : Vector3
var aim_target_distance : float
var aim_target_desired_dist : float = 20

var desired_travel_dir : Vector3
var desired_aim_dir : Vector3

var lead_time: float = .5 #how far ahead do we look for "predictions" of the target
var max_lead_time : float = 3

func _process(_delta: float) -> void:
	match state_machine.state:
		Enemy.State.OFF:
			return #early out if we're turned off
		Enemy.State.IDLE:
			do_idle()

func get_predicted_position() -> Vector3:
	aim_target_distance = (aim_target.global_position - global_position).length()
	var percent_desired_dist : float = aim_target_distance / max(aim_target_desired_dist, 0.01)
	var lead_time_amount : float = clamp(lead_time * percent_desired_dist, 0, max_lead_time)
	aim_target_velocity = GameManager.current_level.player_ship.aim_dir * GameManager.current_level.player_ship.controller.current_speed
	var predicted_position : Vector3 = aim_target.global_position + aim_target_velocity * lead_time_amount
	
	return predicted_position

func do_idle() -> void:
	#idle state waiting
		#we wait for a time before we move on
	#idle state picking
		#we now need to pick a new direction to move in
	#idle state moving
		#we now need to move in that direction
	
	#every state:
		#if we are moving and we collide - alter our direction

	pass

func do_attacking() -> void:
	#set desired desired_travel_dir
	#if we can fire - shoot!
	
	#check collisions and alter move direction
	pass
