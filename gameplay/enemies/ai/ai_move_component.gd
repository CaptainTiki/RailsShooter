extends Node3D
class_name AIMoveComponent

enum Phase {WAIT, MOVE}

@export var state_machine : AIStateMachine

@onready var host : Enemy = $"../.."
@onready var context: AIContext = $"../AIContext"
@onready var travel_probe: AITravelProbe = $"../AITravelProbe"

var phase : Phase = Phase.WAIT

var idle_wait_time : float = 3.0
var current_wait_time : float = 0
var idle_move_time : float = 2.0
var current_move_time : float = 0

var avoid_strength : float = 20 #this needs to end up being a lerp by distance to collision

func _ready() -> void:
	phase = Phase.WAIT
	current_wait_time = randf_range(0,idle_wait_time)
	context.desired_travel_dir = Vector3.ZERO

func _process(delta: float) -> void:
	match state_machine.state:
		Enemy.State.OFF:
			return #early out if we're turned off
		Enemy.State.IDLE:
			do_idle(delta)
		Enemy.State.ATTACKING:
			do_attacking(delta)

func get_rand_direction() -> Vector3:
	return Vector3(randi_range(-1,1), randi_range(-1,1), randi_range(-1,1)).normalized()

func do_movement(delta: float) -> void:
	#TODO: add in some lerp from 0 to max speed once we're AI is working - this is polish 
	check_collisions()
	host.global_position += context.desired_travel_dir * host.movement_speed * delta

func check_collisions() -> void:
	if not travel_probe.colliding:
		return
	
	#TODO: lerp "avoid_strength" by distance to the collision. if we're at 0 distance, the avoid should be 100%
	#context.desired_travel_dir = (context.desired_travel_dir + travel_probe.avoid_dir * avoid_strength).normalized()
	context.desired_travel_dir = travel_probe.avoid_dir

func do_idle(delta: float) -> void:
	match phase:
		Phase.WAIT:
			current_wait_time -= delta
			if current_wait_time >= 0:
				return
			#TODO: check to see if this is too far from our "home location" and pick a new one if so
			context.desired_travel_dir = get_rand_direction()
			phase = Phase.MOVE
			current_move_time = idle_move_time
		Phase.MOVE:
			current_move_time -= delta
			if current_move_time >= 0:
				do_movement(delta)
				return
			current_wait_time = idle_wait_time
			phase = Phase.WAIT

func do_attacking(delta: float) -> void:
	#if we're too close - back away 
	if context.aim_target_distance < context.aim_target_desired_dist:
		#TODO: get the player's direction of travel - and move backwards THAT direction,
		# - maybe bias it so taht we reduce the Y, keeping the ship centered in the tunnels
		context.desired_travel_dir = -(context.get_predicted_position() - global_position).normalized()
	else: #get up close to the target
		context.desired_travel_dir = (context.get_predicted_position() - global_position).normalized()
		
	do_movement(delta)
	pass
