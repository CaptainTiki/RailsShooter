extends Node3D
class_name AI_Controller

enum AIState { IDLE, APPROACH, ATTACK, PEEL_OFF, RECOVER  }
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
@export var peel_off_time: float = 1.2
@export var peel_off_distance: float = 18.0
@export var peel_when_past_player: float = 35.0
@export var attack_start_distance: float = 16.0

#AI - Tunnel Rat
@export var tight_hold_inner: float = 10.0  # too close → reverse
@export var tight_hold_outer: float = 18.0  # too far   → move forward
@export var arrive_slow_radius: float = 25.0  # start slowing down within this distance
@export var tight_forward_match: float = 0.9 # 0..1 how much we match player's forward speed

#AI - Collisions
@export var feeler_length: float = 15.0
@export var wall_avoid_strength: float = 2.5
@export var center_bias_strength: float = 5.2
@export var wall_panic_distance: float = 0.8   # meters; feeler hit closer than this triggers recovery
@export var wall_recovery_time: float = 0.25   # seconds
@export var wall_recovery_boost: bool = true

@onready var ai_controller: Node3D = $AI_Controller
@onready var fwd_upl: RayCast3D = $AI_Controller/Fwd_UPL
@onready var fwd_upr: RayCast3D = $AI_Controller/Fwd_UPR
@onready var fwd_dl: RayCast3D = $AI_Controller/Fwd_DL
@onready var fwd_dr: RayCast3D = $AI_Controller/Fwd_DR
@onready var back_upl: RayCast3D = $AI_Controller/Back_UPL
@onready var back_upr: RayCast3D = $AI_Controller/Back_UPR
@onready var back_dl: RayCast3D = $AI_Controller/Back_DL
@onready var back_dr: RayCast3D = $AI_Controller/Back_DR

var _idle_timer: float = 0.0
var _idle_is_moving: bool = false
var _idle_dir: Vector3 = Vector3.ZERO
var _peel_timer: float = 0.0
var _peel_dir: Vector3 = Vector3.ZERO
var _recover_timer: float = 0.0
var _last_state: AIState = AIState.IDLE

var host : Enemy
var player_ship: Node3D = null


func _ready() -> void:
	
	_idle_timer = idle_wait_time
	_idle_is_moving = false
	ai_state = AIState.IDLE
	space_mode = SpaceMode.TIGHT
	player_ship = resolve_player_ship()
	host = get_parent() as Enemy

func _physics_process(delta: float) -> void:
	ai_tick(delta)
	
	if ai_state != _last_state:
		print("Enemy AI state:", AIState.keys()[ai_state], " space:", SpaceMode.keys()[space_mode])
		_last_state = ai_state

func ai_tick(delta: float) -> void:
	if ai_state != AIState.RECOVER and is_wall_panic_close():
		ai_state = AIState.RECOVER
		_recover_timer = wall_recovery_time

	match ai_state:
		AIState.IDLE:
			do_idle(delta)
		AIState.APPROACH:
			do_approach(delta)
		AIState.ATTACK:
			do_attack(delta)
		AIState.PEEL_OFF:
			do_peel_off(delta)
		AIState.RECOVER:
			do_recover(delta)

func do_idle(delta: float) -> void:
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
		host.rotate_toward_dir(delta, _idle_dir)
	host.move_velocity_toward(delta, target_vel)

func do_approach(delta: float) -> void:
	if player_ship == null:
		ai_state = AIState.IDLE
		return
	
	var target_pos := get_standoff_point()
	var to_target := target_pos - global_position
	var dist := to_target.length()
	
	var dir := to_target.normalized()
	var target_vel : Vector3
	if space_mode == SpaceMode.TIGHT:
		# In tight tunnels, don't "charge the point". Match player forward speed and gently correct.
		var f := get_player_forward().normalized()
		var to_target_fwd : float = (target_pos - global_position).dot(f) # signed distance along tunnel axis

		# Estimate player's forward speed (project their velocity along forward). If you don't have it yet, we fake it as 0.
		var player_vel := Vector3.ZERO
		if player_ship and "measured_velocity" in player_ship:
			player_vel = player_ship.measured_velocity
		var player_fwd_speed := player_vel.dot(f)

		# Desired speed is "match" plus a correction term to reduce the forward error.
		var correction : float = clamp(to_target_fwd * 0.6, -host.reverse_speed, host.movement_speed)
		var desired_fwd_speed := (player_fwd_speed * tight_forward_match) + correction
		desired_fwd_speed = clamp(desired_fwd_speed, -host.reverse_speed, host.movement_speed)

		var base_dir : Vector3= f if desired_fwd_speed >= 0.0 else -f
		target_vel = base_dir * abs(desired_fwd_speed)

		# Still respect walls/centering even while approaching
		var avoid_dir := get_wall_avoid_dir()
		var center_dir := get_center_bias_dir()
		var final_dir := (base_dir + avoid_dir * wall_avoid_strength + center_dir * center_bias_strength).normalized()
		target_vel = final_dir * abs(desired_fwd_speed)

		host.rotate_toward_dir(delta, final_dir)
		host.move_velocity_toward(delta, target_vel)

		# Once we're roughly within the band, enter ATTACK (hold/shoot mode)
		if dist <= tight_hold_outer:
			ai_state = AIState.ATTACK
		return
	
	var spd: float = host.movement_speed if host.approach_speed <= 0.0 else host.approach_speed
	
	# If we're in tight mode, "arrive": slow down as we get close so we don't overshoot.
	if space_mode == SpaceMode.TIGHT:
		var t : float = clamp(dist / arrive_slow_radius, 0.0, 1.0)
		# t=1 far away => full speed, t small near target => slow
		spd *= t
	
	# If we're close enough to our desired standoff location, start "attacking" (next step).
	if dist <= attack_start_distance:
		ai_state = AIState.ATTACK
		return
	
	# Cruise toward it
	target_vel = dir * spd
	
	host.rotate_toward_dir(delta, dir)
	host.move_velocity_toward(delta, target_vel)

func do_attack(delta: float) -> void:
	if player_ship == null:
		ai_state = AIState.IDLE
		return

	if space_mode == SpaceMode.TIGHT:
		# TIGHT: hold position in front of player by creeping forward / reversing.
		var tight_target_pos : Vector3 = get_standoff_point()
		var tight_to_target : Vector3 = tight_target_pos - global_position
		var tight_dist : float = tight_to_target.length()
		var avoid_dir : Vector3 = get_wall_avoid_dir()
		var center_dir : Vector3 = get_center_bias_dir()
		
		# Always try to keep guns pointed generally toward the player.
		var aim_dir : Vector3 = (player_ship.global_position - global_position).normalized()
		host.rotate_toward_dir(delta, aim_dir)

		var tight_target_vel : Vector3 = Vector3.ZERO

		if tight_dist > tight_hold_outer:
			# We're too far from our desired front position → move toward it (forward)
			var _dir : Vector3 = tight_to_target.normalized()
			var final_dir : Vector3 = (_dir
				+ avoid_dir * wall_avoid_strength
				+ center_dir * center_bias_strength
			).normalized()
			tight_target_vel = final_dir * host.movement_speed

		elif tight_dist < tight_hold_inner:
			# We're too close → back up (reverse)
			# Move away from the target position
			var _dir : Vector3 = -get_player_forward().normalized()  # back down the tunnel - not directly backwards
			var final_dir : Vector3 = (_dir
				+ avoid_dir * wall_avoid_strength
				+ center_dir * center_bias_strength
			).normalized()
			tight_target_vel = final_dir * host.reverse_speed

		else:
			# In the hold band → drift/slow down
			tight_target_vel = Vector3.ZERO

		host.move_velocity_toward(delta, tight_target_vel)
		return

	# OPEN: do a high-speed pass in front of the player.
	var target_pos := get_pass_point()
	var to_target := target_pos - global_position
	#var dist := to_target.length()
	var dir := to_target.normalized()

	var want_boost : bool = host.attack_use_boost and host.boost_remaining > 0.0
	host.update_boost(delta, want_boost)
	
	var spd : float = host.boost_speed if want_boost else host.movement_speed
	var target_vel := dir * spd

	host.rotate_toward_dir(delta, dir)
	host.move_velocity_toward(delta, target_vel)

	# Peel off once we've flown far enough past the player (along player's forward axis)
	var p := player_ship.global_position
	var f := get_player_forward().normalized()
	var past_amount := (global_position - p).dot(f)  # + means "in front of player", - means "behind"
	if past_amount >= peel_when_past_player:
		ai_state = AIState.PEEL_OFF
		enter_peel_off()
		return

func do_peel_off(delta: float) -> void:
	if player_ship == null:
		ai_state = AIState.IDLE
		return
		
	_peel_timer -= delta
	
	# Target point is sideways (peel_dir) plus a little forward so it arcs instead of pure strafing.
	var forward := get_player_forward().normalized()
	var target_pos := global_position + (_peel_dir * peel_off_distance) + (forward * 6.0)
	
	var to_target : Vector3 = target_pos - global_position
	var dir : Vector3 = to_target.normalized()
	
	# No boost here; it's a controlled breakaway.
	var target_vel : Vector3 = dir * host.movement_speed
	
	host.rotate_toward_dir(delta, dir)
	host.move_velocity_toward(delta, target_vel)
	
	if _peel_timer <= 0.0:
		ai_state = AIState.APPROACH
		return

func do_recover(delta: float) -> void:
	_recover_timer -= delta

	var avoid_dir := get_wall_avoid_dir()
	var center_dir := get_center_bias_dir()

	# In recovery we prioritize escaping penetration risk over everything else.
	var escape_dir := (avoid_dir * wall_avoid_strength + center_dir * center_bias_strength).normalized()
	if escape_dir == Vector3.ZERO:
		escape_dir = -global_transform.basis.z  # fallback: just go "forward"

	# Optional: use boost to pop off the wall quickly
	var want_boost := wall_recovery_boost and host.boost_remaining > 0.0
	host.update_boost(delta, want_boost)

	var spd := host.boost_speed if want_boost else host.movement_speed
	var target_vel := escape_dir * spd

	host.rotate_toward_dir(delta, escape_dir)
	host.move_velocity_toward(delta, target_vel)

	if _recover_timer <= 0.0:
		ai_state = AIState.ATTACK if distance_to_player() <= awareness_range else AIState.IDLE


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
	return p + f * host.standoff_distance

func get_pass_point() -> Vector3:
	if player_ship == null:
		return global_position
	var p := player_ship.global_position
	var f := get_player_forward().normalized()
	# Aim beyond the player along their forward axis
	return p + f * (host.standoff_distance + host.pass_through_distance)

func enter_peel_off() -> void:
	_peel_timer = peel_off_time

	# Pick left or right relative to the player's facing.
	# If player axis is weird, we'll adjust, but should be fine.
	var right := player_ship.global_transform.basis.x.normalized() if player_ship != null else global_transform.basis.x.normalized()
	var _sign := -1.0 if randf() < 0.5 else 1.0
	_peel_dir = (right * _sign).normalized()

func get_wall_avoid_dir() -> Vector3:
	if ai_controller == null:
		return Vector3.ZERO

	var avoid := Vector3.ZERO

	for child in ai_controller.get_children():
		var ray := child as RayCast3D
		if ray == null:
			continue
		if not ray.is_colliding():
			continue

		# Strength increases as we get closer to the hit.
		var hit_dist := ray.global_position.distance_to(ray.get_collision_point())
		var t : float = clamp(1.0 - (hit_dist / feeler_length), 0.0, 1.0)

		# Push away from the wall using the surface normal.
		avoid += ray.get_collision_normal() * t

	return avoid.normalized()

func get_center_bias_dir() -> Vector3:
	if ai_controller == null:
		return Vector3.ZERO

	var bias := Vector3.ZERO

	for child in ai_controller.get_children():
		var ray := child as RayCast3D
		if ray == null:
			continue
		if not ray.is_colliding():
			continue

		var hit_dist := ray.global_position.distance_to(ray.get_collision_point())
		var t : float = clamp(1.0 - (hit_dist / feeler_length), 0.0, 1.0)

		# The ray points toward the wall; we want to bias AWAY from that direction.
		# Use the ray's forward direction in world space:
		var ray_dir := -ray.global_transform.basis.z.normalized()

		bias += (-ray_dir) * t

	return bias.normalized()

func is_wall_panic_close() -> bool:
	if not ai_controller:
		return false
	
	for child in ai_controller.get_children():
		var ray := child as RayCast3D
		if ray == null or not ray.is_colliding():
			continue
		var hit_dist := ray.global_position.distance_to(ray.get_collision_point())
		if hit_dist <= wall_panic_distance:
			return true
	return false
