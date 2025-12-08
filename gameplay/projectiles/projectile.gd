extends Area3D
class_name Projectile

var direction : Vector3 = Vector3.ZERO
var target : Targetable
var lock_strength : float = 0.01
var damage_type : Globals.DamageType = Globals.DamageType.GENERAL

#needs to move to globals
var proj_homing_strength : float = 0.01 #percent of homing applied PER FRAME (this is the knob we tweak with difficulty settings)

#override values in derived classes
var turn_rate : float = 0.1 #percent of max direction replaced PER FRAME - this changes per proj
var damage : float = 5
var speed : float = 75
var lifetime : float = 20.0 #seconds before we remove the bullet

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		free_projectile()
		
	home_on_target()
	global_position += direction * speed * delta

func home_on_target() -> void:
	if target: #if no target - no lerp is applied to the current direction of travel
		var dir_to_target : Vector3 = (target.global_position - global_position).normalized()
		direction = lerp(direction, dir_to_target, min(1,lock_strength * turn_rate * proj_homing_strength))
		direction = direction.normalized()

func set_direction(dir : Vector3) -> void:
	direction = dir.normalized()

func set_target(tgt : Targetable, lock_str : float) -> void:
	target = tgt
	lock_strength = lock_str

func set_speed(spd : float) -> void:
	speed = spd

func free_projectile() -> void:
	#in case we need to do something other than just free later
	queue_free()
