extends Node3D
class_name WeaponComponent

@export var inventory : InventoryComponent
@export var fire_rate : float = 0.5 #bullets per second

@onready var muzzle: Marker3D = $Muzzle
@onready var fire_rate_timer: Timer = $Timer

const BULLET_BASE = preload("uid://bym866vprinl4")

var primary_power_cost = 1

##Spawns a primary bullet at the muzzle, consumes power
func fire_primary() -> void:
	if inventory.current_power >= primary_power_cost and fire_rate_timer.is_stopped():
		var new_bullet : Bullet = BULLET_BASE.instantiate()
		add_child.call_deferred(new_bullet)
		new_bullet.global_position = muzzle.global_position
		new_bullet.rotation = muzzle.rotation
		new_bullet.direction = -muzzle.global_transform.basis.z  #TODO: need to check this if correct direction later
		fire_rate_timer.start(fire_rate)
		inventory.use_power(primary_power_cost)

##Fires selected special bullet of currently selected slot, consumes no power
func fire_special() -> void:
	if fire_rate_timer.is_stopped():
		var bullet_scene = inventory.get_available_bullet()
		if bullet_scene == null:
			return  #this means we had no available bullet to fire
		var new_bullet : Bullet = bullet_scene.instantiate()
		add_child.call_deferred(new_bullet)
		new_bullet.global_position = muzzle.global_position
		new_bullet.rotation = muzzle.rotation
		new_bullet.direction = -muzzle.global_transform.basis.z  #TODO: need to check this if correct direction later
		fire_rate_timer.start(fire_rate)
		inventory.consume_selected_special()
		pass
	pass

func get_muzzle_position() -> Vector3:
	return muzzle.global_position

func get_muzzle_direction() -> Vector3:
	return -muzzle.global_transform.basis.z
