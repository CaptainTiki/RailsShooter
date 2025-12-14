extends Weapon
class_name ProjectileWeapon

@export var projo_scene : PackedScene = preload("res://gameplay/projectiles/bullets/basic_bullet_proj.tscn")
@onready var fire_rate_timer: Timer = $Fire_Rate_Timer

func _ready() -> void:
	ammo_type = Globals.AmmoType.BULLET_SM

func fire_pressed() -> void:
	if not can_fire():
		return
	
	if try_consume_ammo():
		spawn_projectile(projo_scene)
		fire_rate_timer.start()

func fire_released() -> void:
	pass

func can_fire() -> bool:
	if !fire_rate_timer.is_stopped(): #cooldown not ready
		return false
	if not hub.has_ammo(ammo_type, ammo_cost_per_shot): #not enough ammo to shoot
		return false
	return true

func spawn_projectile(scene: PackedScene) -> void:
	var tgt: Targetable = hub.player_ship.current_target
	var new_projo: Projectile = scene.instantiate() as Projectile
	if tgt:
		var to_target: Vector3 = (tgt.global_position - global_position).normalized()
		var dot_product: float = clamp(hub.player_ship.aim_dir.dot(to_target), 0.01, 1.0)
		var dir: Vector3 = lerp(hub.player_ship.aim_dir, to_target, dot_product)
		new_projo.set_direction(dir)
		new_projo.set_target(tgt, dot_product)
	else:
		new_projo.set_direction(hub.player_ship.aim_dir)
	hub.bullet_parent.add_child(new_projo)
	new_projo.global_position = global_position
	
	weapon_fired.emit()
