extends Node3D
class_name  PlayerController

@export var player_ship : PlayerShip
@export var input : PlayerInput
@export var stats : ShipStats

func _physics_process(delta: float) -> void:
	# Update aim first (where the reticle is pointing)

	var stick: Vector2 = input.virtual_stick
	var basis := player_ship.global_transform.basis
	var euler := basis.get_euler()  # x=pitch, y=yaw, z=roll

	# --- YAW: follow the aim dir horizontally ---
	var aim_dir := player_ship.aim_dir.normalized()
	# Forward is -Z, so yaw is based on X / -Z
	var target_yaw := atan2(aim_dir.x, -aim_dir.z)
	var yaw_speed := stats.turn_speed
	euler.y = lerp_angle(euler.y, target_yaw, yaw_speed * delta)

	# --- PITCH: from stick.y, auto-level when neutral ---
	var deadzone := 0.1  # tweak if needed
	var max_pitch_deg := 25.0  # how far up/down you can pitch
	var max_pitch_rad := deg_to_rad(max_pitch_deg)
	var target_pitch := 0.0

	if abs(stick.y) > deadzone:
		# stick.y > 0 = up on your stick, so pitch nose up
		target_pitch = clamp(-stick.y * max_pitch_rad, -max_pitch_rad, max_pitch_rad)
	# else: we leave target_pitch = 0.0 → auto-level

	var pitch_speed := stats.turn_speed
	euler.x = lerp(euler.x, target_pitch, pitch_speed * delta)

	# --- ROLL: for now just damp back toward 0 ---
	var roll_damp := 3.0
	euler.z = lerp(euler.z, 0.0, roll_damp * delta)

	# Apply the new rotation
	basis = Basis.from_euler(euler)
	player_ship.global_transform.basis = basis

	# --- MOVE: always forward along the ship's nose ---
	var forward := -player_ship.global_basis.z
	player_ship.global_position += forward * stats.travel_speed * delta
