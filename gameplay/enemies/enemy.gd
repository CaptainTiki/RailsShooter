extends Node3D
class_name Enemy

enum State {OFF, STUNNED, ATTACKING, IDLE}
enum AIState { IDLE, APPROACH, ATTACK, PEEL_OFF }
enum SpaceMode { TIGHT, OPEN }

@export var space_mode: SpaceMode = SpaceMode.OPEN
@export var ai_state: AIState = AIState.IDLE
#AI - OpenSpace
@export var idle_wait_time: float = 1.0
@export var idle_move_time: float = 2.0
@export var idle_drift_speed: float = 6.0
@export var awareness_range: float = 80.0
@export var stop_distance: float = 6.0 # don't try to sit inside the player
@export var approach_speed: float = 0.0 # 0 means "use movement_speed"
@export var pass_through_distance: float = 30.0  # how far past the player we aim during a pass
@export var attack_use_boost: bool = true
@export var peel_off_time: float = 1.2
@export var peel_off_distance: float = 18.0
@export var peel_when_past_player: float = 35.0
@export var attack_start_distance: float = 16.0
#AI - Tunnel Rat
@export var tight_hold_inner: float = 10.0  # too close → reverse
@export var tight_hold_outer: float = 18.0  # too far   → move forward

#Movement
@export var turn_rate: float = 120.0    # degrees/sec
@export var deceleration: float = 7.0       # if different than accel
@export var reverse_speed: float = 16.0  # usually smaller than forward
@export var allow_reverse: bool = true
@export var movement_speed : float = 22
@export var boost_speed : float = 55
@export var acceleration : float = 15
@export var standoff_distance: float = 30.0
# Boost is measured in seconds of available boost time.
@export var boost_capacity_seconds: float = 2.5
@export var boost_regen_per_sec: float = 0.7



var _idle_timer: float = 0.0
var _idle_is_moving: bool = false
var _idle_dir: Vector3 = Vector3.ZERO
var _peel_timer: float = 0.0
var _peel_dir: Vector3 = Vector3.ZERO

var _velocity: Vector3 = Vector3.ZERO

var boost_remaining: float = 0.0

@onready var health: HealthComponent = $Health
@onready var target_node: ShipTarget = $Target_Node
@onready var parent_room: Room = $"../.."
@onready var floating_progress_bar: FloatingProgressBar = $FloatingProgressBar

@onready var rotation_handle: Node3D = $Rotation_Handle

var pickup_scene : PackedScene = preload("res://gameplay/pickups/ship-ammo/torp_ammo_pickup.tscn")
var drop_spread : float = 0.5  # ~28 degrees
var drop_speed : float = 5

var player_ship: Node3D = null

var _last_state: AIState = AIState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_room.destroying_room.connect(_destroy)
	health.connect("died", _on_died)
	target_node.register()
	player_ship = resolve_player_ship()
	_idle_timer = idle_wait_time
	_idle_is_moving = false
	ai_state = AIState.IDLE
	space_mode = SpaceMode.TIGHT
	boost_remaining = boost_capacity_seconds
	floating_progress_bar.set_target(self)
	floating_progress_bar.value = health.current_health
	floating_progress_bar.max_value = health.max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ai_tick(delta)
	
	if ai_state != _last_state:
		print("Enemy AI state:", AIState.keys()[ai_state], " space:", SpaceMode.keys()[space_mode])
		_last_state = ai_state
	floating_progress_bar.value = health.current_health

func ai_tick(delta: float) -> void:
	# No movement yet. We’re just wiring structure.
	match ai_state:
		AIState.IDLE:
			if player_ship != null and distance_to_player() <= awareness_range:
				ai_state = AIState.APPROACH
				return
			_idle_timer -= delta

			if _idle_timer <= 0.0:
				_idle_is_moving = not _idle_is_moving
				_idle_timer = idle_move_time if _idle_is_moving else idle_wait_time

				if _idle_is_moving:
					# Pick a random direction on the X/Y plane (no tunnel bias yet)
					var angle := randf() * TAU
					_idle_dir = Vector3(cos(angle), randf_range(-0.4, 0.4), sin(angle)).normalized()

			# Decide target velocity
			var target_vel := Vector3.ZERO
			if _idle_is_moving:
				# Gentle wander so it keeps making small steering corrections
				_idle_dir = (_idle_dir + Vector3(randf_range(-0.15, 0.15), randf_range(-0.08, 0.08), randf_range(-0.15, 0.15)) * delta).normalized()
				target_vel = _idle_dir * idle_drift_speed

			# Turn and move
			if _idle_is_moving:
				rotate_toward_dir(delta, _idle_dir)
			move_velocity_toward(delta, target_vel)
		AIState.APPROACH:
			if player_ship == null:
				ai_state = AIState.IDLE
				return
				
			var target_pos := get_standoff_point()
			var to_target := target_pos - global_position
			var dist := to_target.length()
			
			# If we're close enough to our desired standoff location, start "attacking" (next step).
			if dist <= attack_start_distance:
				ai_state = AIState.ATTACK
				return
				
			var dir := to_target.normalized()
			
			# Cruise toward it
			var spd := movement_speed if approach_speed <= 0.0 else approach_speed
			var target_vel := dir * spd
			
			rotate_toward_dir(delta, dir)
			move_velocity_toward(delta, target_vel)
		AIState.ATTACK:
			if player_ship == null:
				ai_state = AIState.IDLE
				return

			if space_mode == SpaceMode.TIGHT:
				# TIGHT: hold position in front of player by creeping forward / reversing.
				var tight_target_pos : Vector3 = get_standoff_point()
				var tight_to_target : Vector3 = tight_target_pos - global_position
				var tight_dist : float = tight_to_target.length()

				# Always try to keep guns pointed generally toward the player.
				var aim_dir := (player_ship.global_position - global_position).normalized()
				rotate_toward_dir(delta, aim_dir)

				var tight_target_vel : Vector3 = Vector3.ZERO

				if tight_dist > tight_hold_outer:
					# We're too far from our desired front position → move toward it (forward)
					var _dir : Vector3 = tight_to_target.normalized()
					tight_target_vel = _dir * movement_speed

				elif tight_dist < tight_hold_inner:
					# We're too close → back up (reverse)
					# Move away from the target position
					var _dir : Vector3 = (-tight_to_target).normalized()
					tight_target_vel = _dir * reverse_speed

				else:
					# In the hold band → drift/slow down
					tight_target_vel = Vector3.ZERO

				move_velocity_toward(delta, tight_target_vel)
				return

			# OPEN: do a high-speed pass in front of the player.
			var target_pos := get_pass_point()
			var to_target := target_pos - global_position
			#var dist := to_target.length()
			var dir := to_target.normalized()

			var want_boost := attack_use_boost and boost_remaining > 0.0
			update_boost(delta, want_boost)
			
			var spd : float = boost_speed if want_boost else movement_speed
			var target_vel := dir * spd

			rotate_toward_dir(delta, dir)
			move_velocity_toward(delta, target_vel)

			# Peel off once we've flown far enough past the player (along player's forward axis)
			var p := player_ship.global_position
			var f := get_player_forward().normalized()
			var past_amount := (global_position - p).dot(f)  # + means "in front of player", - means "behind"
			if past_amount >= peel_when_past_player:
				ai_state = AIState.PEEL_OFF
				enter_peel_off()
				return
			
		AIState.PEEL_OFF:
			if player_ship == null:
				ai_state = AIState.IDLE
				return
				
			_peel_timer -= delta
			
			# Target point is sideways (peel_dir) plus a little forward so it arcs instead of pure strafing.
			var forward := get_player_forward().normalized()
			var target_pos := global_position + (_peel_dir * peel_off_distance) + (forward * 6.0)
			
			var to_target := target_pos - global_position
			var dir := to_target.normalized()
			
			# No boost here; it's a controlled breakaway.
			var target_vel := dir * movement_speed
			
			rotate_toward_dir(delta, dir)
			move_velocity_toward(delta, target_vel)
			
			if _peel_timer <= 0.0:
				ai_state = AIState.APPROACH
				return

func rotate_toward_dir(delta: float, desired_dir: Vector3) -> void:
	if desired_dir.length() < 0.0001:
		return

	# Godot ships: -Z is "forward" convention for most models.
	var target_pos: Vector3 = global_position + desired_dir.normalized()
	var current_basis: Basis = global_transform.basis
	var desired_transform: Transform3D = global_transform.looking_at(target_pos, Vector3.UP)
	var desired_basis: Basis = desired_transform.basis

	# Clamp rotation speed (turn_rate is degrees/sec)
	var t : float = clamp((turn_rate * deg_to_rad(1.0)) * delta, 0.0, 1.0)
	# Slerp basis using quaternions for smooth turning
	var q_from := current_basis.get_rotation_quaternion()
	var q_to := desired_basis.get_rotation_quaternion()
	var q_new := q_from.slerp(q_to, t)
	global_transform.basis = Basis(q_new)

func move_velocity_toward(delta: float, target_vel: Vector3) -> void:
	var diff: Vector3 = target_vel - _velocity
	if diff.length() < 0.001:
		_velocity = target_vel
		return

	# Choose accel or decel depending on whether we're trying to speed up or slow down.
	var rate: float = acceleration
	if target_vel.length() < _velocity.length():
		rate = deceleration

	var max_step: float = rate * delta
	if diff.length() <= max_step:
		_velocity = target_vel
	else:
		_velocity += diff.normalized() * max_step

	global_position += _velocity * delta


func _on_died() -> void:
	var drop = pickup_scene.instantiate() as Pickup
	get_parent().add_child(drop)
	var base_dir := global_transform.basis.y
	var random_offset := Vector3(
		randf_range(-drop_spread, drop_spread),
		0.0,
		randf_range(-drop_spread, drop_spread)
	)
	var dir : Vector3 = (base_dir + random_offset).normalized()
	var vel : Vector3 = dir * drop_speed
	drop.spawn_pickup(
		vel,
		Vector3(randf() * TAU, randf()* 3, randf()* TAU),
		4,
		1.5)
	drop.global_position = global_position
	target_node.unregister()
	queue_free()

func _destroy() -> void:
	target_node.unregister()
	queue_free()

func adjust_damage(amount : float, _type : Globals.DamageType) -> float:
	match _type:
		Globals.DamageType.MINING:
			return amount * 0.1 #we take 1/10 damage from mining lazers
		_:
			return amount #take full damage from everything else

func take_damage(amount : float, _type : Globals.DamageType) -> void:
	health.take_damage(amount, _type)

func update_boost(delta: float, is_boosting: bool) -> void:
	if is_boosting and boost_remaining > 0.0:
		boost_remaining = max(0.0, boost_remaining - delta)
	else:
		boost_remaining = min(boost_capacity_seconds, boost_remaining + boost_regen_per_sec * delta)

func resolve_player_ship() -> Node3D:
	if GameManager == null:
		return null
	if GameManager.current_level == null:
		return null
	if not GameManager.current_level.has_node("PlayerShip"):
		# If your player ship node isn't named PlayerShip, we'll adjust next step.
		return GameManager.current_level.player_ship if "player_ship" in GameManager.current_level else null
	return GameManager.current_level.get_node("PlayerShip") as Node3D

func distance_to_player() -> float:
	if player_ship == null:
		return INF
	return global_position.distance_to(player_ship.global_position)

func get_player_forward() -> Vector3:
	if player_ship == null:
		return -global_transform.basis.z
	return -player_ship.global_transform.basis.z

func get_standoff_point() -> Vector3:
	if player_ship == null:
		return global_position
	var p := player_ship.global_position
	var f := get_player_forward().normalized()
	return p + f * standoff_distance

func get_pass_point() -> Vector3:
	if player_ship == null:
		return global_position
	var p := player_ship.global_position
	var f := get_player_forward().normalized()
	# Aim beyond the player along their forward axis
	return p + f * (standoff_distance + pass_through_distance)

func enter_peel_off() -> void:
	_peel_timer = peel_off_time

	# Pick left or right relative to the player's facing.
	# If player axis is weird, we'll adjust, but should be fine.
	var right := player_ship.global_transform.basis.x.normalized() if player_ship != null else global_transform.basis.x.normalized()
	var _sign := -1.0 if randf() < 0.5 else 1.0
	_peel_dir = (right * _sign).normalized()
