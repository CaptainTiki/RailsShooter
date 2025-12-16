extends Node3D
class_name AIMoveComponent

enum Phase {WAIT, MOVE}

@export var state_machine : AIStateMachine

@onready var host : Enemy = $"../.."
@onready var context: AIContext = $"../AIContext"
@onready var ai_state_machine: AIStateMachine = $"../AiStateMachine"
@onready var travel_probe: AITravelProbe = $"../AITravelProbe"

var phase : Phase = Phase.WAIT

var idle_wait_time : float = 3.0
var current_wait_time : float = 0
var idle_move_time : float = 2.0
var current_move_time : float = 0

var steering_weight : float = 1.0

var t : float = 0 #time counter for movement
var orbit_speed : float = 1
var orbit_radius_x : float = 1
var orbit_radius_y : float = 1
func _ready() -> void:
	phase = Phase.WAIT
	current_wait_time = randf_range(0, idle_wait_time)
	context.desired_travel_dir = Vector3.ZERO
	context.current_speed = host.movement_speed
	ai_state_machine.state_changed.connect(_on_state_changed)

func _physics_process(delta: float) -> void:
	context.current_speed = lerp(context.current_speed, context.desired_speed, host.acceleration * delta)
	
	match state_machine.state:
		Enemy.State.OFF:
			return #early out if we're turned off
		Enemy.State.IDLE:
			do_idle(delta)
		Enemy.State.ATTACKING:
			do_attacking(delta)

func get_rand_direction() -> Vector3:
	var vec : Vector3
	while vec == Vector3.ZERO:
		vec = Vector3(randi_range(-1,1), randi_range(-1,1), randi_range(-1,1)).normalized()
	return vec

func do_movement(delta: float) -> void:
	context.current_speed = lerp(context.current_speed, context.desired_speed, host.acceleration * delta)
	host.global_position += context.steering_dir * context.current_speed * delta

func adjust_steering_collisions() -> void:
	if not travel_probe.colliding:
		context.steering_dir = context.desired_travel_dir
		return
		
	var avoid_steering : Vector3 = travel_probe.get_avoid_dir()
	var avoid_weight : float = travel_probe.get_avoid_weight()
	var centering_steering : Vector3 = travel_probe.get_centering_dir()
	var centering_weight : float = travel_probe.get_centering_weight()

	context.steering_dir = ( 
		context.desired_travel_dir * steering_weight +
		avoid_steering * avoid_weight +
		centering_steering * centering_weight).normalized()

func do_idle(delta: float) -> void:
	match phase:
		Phase.WAIT:
			current_wait_time -= delta
			if current_wait_time >= 0:
				return
			#TODO: check to see if this is too far from our "home location" and pick a new one if so
			context.desired_travel_dir = get_rand_direction()
			context.desired_speed = host.movement_speed
			phase = Phase.MOVE
			current_move_time = idle_move_time
		Phase.MOVE:
			current_move_time -= delta
			if current_move_time >= 0:
				#TODO: check if we're close and lerp down to zero speed - so we don't overshoot
				adjust_steering_collisions()
				do_movement(delta)
				return
			current_wait_time = idle_wait_time
			context.desired_speed = 0
			phase = Phase.WAIT

func do_attacking(delta: float) -> void:
	var standoff_point = calc_standoff_point() #get our point we want to move to
	var forward = -GameManager.current_level.player_ship.global_basis.z
	var right = GameManager.current_level.player_ship.global_basis.x
	var up = GameManager.current_level.player_ship.global_basis.y
	var anchor = standoff_point + forward
	t += orbit_speed * delta
	var offset = right * cos(t) * orbit_radius_x + up * sin(t) * orbit_radius_y
	var orbit_target = anchor + offset
	var to_target = orbit_target - global_position
	
	#if we're too close - back away 
	if to_target.length() > context.aim_target_distance_buffer:
		context.desired_travel_dir = to_target.normalized()
	else:
		var radial = (global_position - anchor).normalized()
		var tangent = forward.cross(radial).normalized()
		context.desired_travel_dir = tangent
		pass
		

	adjust_steering_collisions() #check for collisions
	do_movement(delta)
	pass

func calc_standoff_point() -> Vector3:
	var predicted = context.get_predicted_position()
	var self_pos = global_position
	var to_pred = predicted - self_pos
	var dir = to_pred.normalized()
	return predicted - dir * context.aim_target_desired_dist

func _on_state_changed() -> void:
	match state_machine.state:
		Enemy.State.OFF:
			context.desired_speed = 0
		Enemy.State.IDLE:
			context.desired_speed = host.movement_speed
		Enemy.State.ATTACKING:
			context.desired_speed = host.attack_speed
