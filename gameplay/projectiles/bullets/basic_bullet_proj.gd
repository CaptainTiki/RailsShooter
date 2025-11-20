extends Projectile
class_name BasicBulletProj

func _ready() -> void:
	turn_rate = 0.1
	damage = 5
	speed = 75
	lifetime = 8
