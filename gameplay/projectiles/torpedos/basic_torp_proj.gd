extends Projectile
class_name BasicTorpProj

func _ready() -> void:
	turn_rate = 0.4
	damage = 25
	speed = 40
	lifetime = 8
