extends Area3D
class_name Projectile

var speed : float = 75
var direction : Vector3 = Vector3.ZERO

var damage : float = 5

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func set_direction(dir : Vector3) -> void:
	direction = dir

func set_speed(spd : float) -> void:
	speed = spd
