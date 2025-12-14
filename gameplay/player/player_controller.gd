extends Node3D
class_name  PlayerController

@export var player_ship : PlayerShip
@export var input : PlayerInput
@export var stats : ShipStats
@export var reticle: Reticle2D

var current_speed: float = 0.0
var max_speed: float = 0.0
var min_speed: float = 0.0

func _ready() -> void:
	max_speed = stats.travel_speed
	min_speed = -stats.travel_speed * stats.reverse_factor
	# start at some forward speed; adjust if you want to start stopped
	current_speed = max_speed * 0.25  # 1/4 start speed

func brake(delta : float) -> void:
	current_speed -= stats.throttle_change_speed * delta * 4

func boost(delta : float) -> void:
	current_speed += stats.throttle_change_speed * delta * 4

func _physics_process(delta: float) -> void:
	if not player_ship or not stats:
		return

	var roll_left  := input.bank_left_pressed
	var roll_right := input.bank_right_pressed

	# --- THROTTLE UPDATE ---
	if input.throttle_up_pressed:
		current_speed += stats.throttle_change_speed * delta
	elif input.throttle_down_pressed:
		current_speed -= stats.throttle_change_speed * delta

	# clamp between full reverse and full forward
	current_speed = clamp(current_speed, min_speed, max_speed)

	# normalized speed magnitude (0 = stopped, 1 = max forward)
	var speed_mag : float = abs(current_speed)
	var speed_norm : float = 0.0
	if max_speed > 0.0:
		speed_norm = clamp(speed_mag / max_speed, 0.0, 1.0)
	
		# --- Reticle offset → normalized input (-1..1) ---
	var ship_basis : Basis = player_ship.global_transform.basis
	var euler := ship_basis.get_euler()  # x = pitch, y = yaw, z = roll

	var viewport_size := get_viewport().get_visible_rect().size
	var center := viewport_size * 0.5
	var reticle_pos := reticle.position

	var offset := reticle_pos - center
	var norm := Vector2(
		clamp(offset.x / center.x, -1.0, 1.0),
		clamp(offset.y / center.y, -1.0, 1.0)
	)

	# --- ROLL: manual first, then auto-bank if no input ---
	var target_roll := 0.0
	if roll_left:
		target_roll = stats.max_roll_angle
	elif roll_right:
		target_roll = -stats.max_roll_angle
	else:
		target_roll = -norm.x * stats.max_roll_angle

	euler.z = lerp(euler.z, target_roll, stats.roll_speed * delta)

	# how banked are we?
	var bank_factor := 0.0
	if stats.max_roll_angle != 0.0:
		bank_factor = clamp(euler.z / stats.max_roll_angle, -1.0, 1.0)
	var bank_amount : float = abs(bank_factor)

	# --- TURN SCALE BASED ON SPEED ---
	# slow (speed_norm ≈ 0)  → full turn
	# fast (speed_norm ≈ 1)  → reduced turn
	var max_turn_scale := 1.0   # at zero speed
	var min_turn_scale := 0.5   # at max forward speed
	var turn_scale : float = lerp(max_turn_scale, min_turn_scale, speed_norm)

	# base: pitch = 1.0, yaw = 0.5, both scaled by speed
	var base_pitch_speed : float = stats.turn_speed * turn_scale
	var base_yaw_speed   : float = stats.turn_speed * 0.5 * turn_scale

	# --- PITCH (up/down), still clamped, weaker when banked ---
	var max_pitch := stats.max_pitch_angle
	var target_pitch := norm.y * max_pitch * Globals.invert_y
	var pitch_speed : float = lerp(base_pitch_speed, base_pitch_speed * 0.5, bank_amount)
	euler.x = lerp(euler.x, target_pitch, pitch_speed * delta)

	# --- YAW: TURN RATE, boosted when banking into the turn ---
	var yaw_input := -norm.x
	var yaw_speed := base_yaw_speed

	if yaw_input != 0.0 and bank_factor != 0.0:
		var same_dir : float = sign(yaw_input) == sign(bank_factor)
		if same_dir:
			yaw_speed *= (1.0 + stats.pitch_turn_bonus * bank_amount)

	euler.y += yaw_input * yaw_speed * delta

	# apply rotation
	ship_basis = Basis.from_euler(euler)
	player_ship.global_transform.basis = ship_basis

	# --- MOVE: forward or backward based on current_speed ---
	var forward := -player_ship.global_basis.z
	player_ship.global_position += forward * current_speed * delta
