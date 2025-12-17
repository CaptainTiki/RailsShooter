extends Node3D
class_name Enemy

enum State {OFF, STUNNED, ATTACKING, IDLE}

#Movement
@export var turn_rate: float = 120.0    # degrees/sec
@export var deceleration: float = 27.0       # if different than accel
@export var reverse_speed: float = 24.0  # usually smaller than forward
@export var allow_reverse: bool = true
@export var movement_speed : float = 50
@export var approach_speed : float = 60
@export var boost_speed : float = 85
@export var acceleration : float = 15
@export var standoff_distance : float = 44
@export var collision_margin: float = 0.15
@export var scrape_damping : float = 0.8
@export var pass_through_distance : float = 12

# Boost is measured in seconds of available boost time.
@export var boost_capacity_seconds: float = 5.5
@export var boost_regen_per_sec: float = 0.7
@export var attack_use_boost: bool = true

@onready var ai_controller: Node3D = $AI_Controller
@onready var fwd_upl: RayCast3D = $AI_Controller/Fwd_UPL
@onready var fwd_upr: RayCast3D = $AI_Controller/Fwd_UPR
@onready var fwd_dl: RayCast3D = $AI_Controller/Fwd_DL
@onready var fwd_dr: RayCast3D = $AI_Controller/Fwd_DR
@onready var back_upl: RayCast3D = $AI_Controller/Back_UPL
@onready var back_upr: RayCast3D = $AI_Controller/Back_UPR
@onready var back_dl: RayCast3D = $AI_Controller/Back_DL
@onready var back_dr: RayCast3D = $AI_Controller/Back_DR

@onready var hull_cast: ShapeCast3D = $HullCast

@onready var health: HealthComponent = $Health
@onready var target_node: ShipTarget = $Target_Node
@onready var parent_room: Room = $"../.."
@onready var floating_progress_bar: FloatingProgressBar = $FloatingProgressBar

@onready var rotation_handle: Node3D = $Rotation_Handle

var _velocity: Vector3 = Vector3.ZERO

var boost_remaining: float = 0.0

var pickup_scene : PackedScene = preload("res://gameplay/pickups/ship-ammo/torp_ammo_pickup.tscn")
var drop_spread : float = 0.5  # ~28 degrees
var drop_speed : float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_room.destroying_room.connect(_destroy)
	health.connect("died", _on_died)
	target_node.register()
	boost_remaining = boost_capacity_seconds
	floating_progress_bar.set_target(self)
	floating_progress_bar.value = health.current_health
	floating_progress_bar.max_value = health.max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	floating_progress_bar.value = health.current_health

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

	# Choose accel or decel depending on whether we're trying to speed up or slow down.
	var rate: float = acceleration
	if target_vel.length() < _velocity.length():
		rate = deceleration

	var max_step: float = rate * delta
	if diff.length() <= max_step:
		_velocity = target_vel
	else:
		_velocity += diff.normalized() * max_step

	var motion: Vector3 = _velocity * delta
	
	if motion.length() < 0.0001:
		return

	# Sweep the hull toward where we want to go this frame
	hull_cast.target_position = motion
	hull_cast.force_shapecast_update()

	if hull_cast.is_colliding():
		# Move up to the wall (minus a small margin)
		var hit_dist: float = hull_cast.get_closest_collision_safe_fraction() * motion.length()
		var safe_dist: float = max(0.0, hit_dist - collision_margin)
		var safe_motion: Vector3 = motion.normalized() * safe_dist
		global_position += safe_motion
		
		# Try to slide along the wall with the remaining motion this frame
		var remaining: Vector3 = motion - safe_motion
		var n : Vector3 = hull_cast.get_collision_normal(0).normalized()
		
		if remaining.length() > 0.0001:

			var slide_motion : Vector3 = remaining.slide(n)  # remove component into the wall

			if slide_motion.length() > 0.0001:
				hull_cast.target_position = slide_motion
				hull_cast.force_shapecast_update()
				if not hull_cast.is_colliding():
					global_position += slide_motion

		# Slide along the wall by removing velocity into the wall normal
		var into_wall: float = _velocity.dot(n)
		if into_wall < 0.0:
			_velocity -= n * into_wall
			_velocity *= scrape_damping

		# Optional: sparks/hit feedback later (we’ll hook a signal next)
	else:
		global_position += motion



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
