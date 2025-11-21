extends Node3D
class_name Weapon

@onready var fire_rate_timer: Timer = $GunsFireRate #set to 0.125 8/s
@onready var torp_fire_rate: Timer = $TorpFireRate #set to 1.0 1/s

@onready var targeting_component: TargetingComponent = $"../TargetingComponent"

var max_torps : int = 6
var current_torps : int = 6

var max_power : float = 100
var current_power : float = 100
var power_regen_rate : float = 20
var power_per_shot : float = 12

var bullet_scene = preload("res://gameplay/projectiles/bullets/basic_bullet_proj.tscn")
var torp_scene = preload("res://gameplay/projectiles/torpedos/basic_torp_proj.tscn")

func _process(delta: float) -> void:
	current_power = min(max_power, current_power + (power_regen_rate * delta))

func fire_guns() -> void:
	if !fire_rate_timer.is_stopped(): #cooldown not ready
		return
		
	if current_power < power_per_shot: #not enough ammo to shoot
		return
	
	spawn_projectile(bullet_scene)
	current_power = max(0, current_power - power_per_shot)
	fire_rate_timer.start()
					
func fire_torp() -> void:
	if !torp_fire_rate.is_stopped(): #cooldown not ready
		return
		
	if current_torps <= 0: #not enough ammo to shoot
		return
		
	spawn_projectile(torp_scene)
	current_torps = max(0, current_torps - 1)
	torp_fire_rate.start()


func spawn_projectile(scene : PackedScene)-> void:
	var tgt : Targetable = targeting_component.current_target
	var ship_forward : Vector3 = -global_basis.z
	var new_projo : Projectile = scene.instantiate() as Projectile
	var bullet_parent : Node3D = get_tree().get_first_node_in_group("BulletsParent")
	
	if tgt:
		var dir_to_target : Vector3 = (tgt.global_position - global_position).normalized()
		var dot_product : float = ship_forward.dot(dir_to_target)
		dot_product = clamp(dot_product, 0.01, 1)
		var dir : Vector3 = lerp(ship_forward, dir_to_target, dot_product)
		new_projo.set_direction(dir)
		new_projo.set_target(tgt,dot_product)
	else:
		new_projo.set_direction(ship_forward)
		
	bullet_parent.add_child(new_projo)
	new_projo.global_position = global_position

func add_torp_ammo(num : int)-> void:
	current_torps = min(max_torps, current_torps + num)
