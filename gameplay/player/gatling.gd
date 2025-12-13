extends Weapon
class_name GatlingWeapon

@export var reticle_ui: Control

@onready var fire_rate_timer: Timer = $GunsFireRate #set to 0.125 8/s
@onready var torp_fire_rate: Timer = $TorpFireRate #set to 1.0 1/s

@onready var ship_stats: ShipStats = %ShipStats

@onready var targeting_component: TargetingComponent = $"../TargetingComponent"

var current_torps : int = 0
var current_power : float = 100
var power_regen_rate : float = 20
var power_per_shot : float = 12

var bullet_scene = preload("res://gameplay/projectiles/bullets/basic_bullet_proj.tscn")
var torp_scene = preload("res://gameplay/projectiles/torpedos/basic_torp_proj.tscn")

func _ready() -> void:
	ship_stats.stats_updated.connect(_update_stats)
	current_torps = ship_stats.max_torps

func _process(delta: float) -> void:
	current_power = min(ship_stats.max_gun_power, current_power + (power_regen_rate * delta))

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

func spawn_projectile(scene: PackedScene) -> void:
	var tgt: Targetable = targeting_component.current_target

	# 1) Build aim ray from camera + reticle
	var aim_origin: Vector3 = global_position
	var aim_dir: Vector3 = -global_basis.z   # fallback

	if camera_rig.camera:
		var viewport_rect := get_viewport().get_visible_rect()
		var reticle_screen_pos: Vector2 = viewport_rect.size * 0.5
		if reticle_ui:
			reticle_screen_pos = reticle_ui.get_global_position()

		aim_origin = camera_rig.camera.project_ray_origin(reticle_screen_pos)
		aim_dir    = camera_rig.camera.project_ray_normal(reticle_screen_pos).normalized()

	# 2) Raycast to find aim point
	var max_range: float = targeting_component.max_range
	var space_state := get_world_3d().direct_space_state
	var ray_params : PhysicsRayQueryParameters3D
	ray_params = PhysicsRayQueryParameters3D.create(
		aim_origin,
		aim_origin+aim_dir *max_range,
		0xFFFFFFFF
		)
	var result := space_state.intersect_ray(ray_params)

	var aim_point: Vector3 = aim_origin + aim_dir * max_range
	if result and result.has("position"):
		aim_point = result["position"]

	# 3) Spawn projectile and give it a direction
	var new_projo: Projectile = scene.instantiate() as Projectile
	var bullet_parent: Node3D = get_tree().get_first_node_in_group("BulletsParent")

	var base_dir: Vector3 = (aim_point - global_position).normalized()

	if tgt:
		var to_target: Vector3 = (tgt.global_position - global_position).normalized()
		var dot_product: float = clamp(base_dir.dot(to_target), 0.01, 1.0)
		var dir: Vector3 = lerp(base_dir, to_target, dot_product)
		new_projo.set_direction(dir)
		new_projo.set_target(tgt, dot_product)
	else:
		new_projo.set_direction(base_dir)

	bullet_parent.add_child(new_projo)
	new_projo.global_position = global_position


func add_torp_ammo(num : int)-> void:
	current_torps = min(ship_stats.max_torps, current_torps + num)

func _update_stats() -> void:
	current_torps = ship_stats.max_torps
	current_power = ship_stats.max_gun_power
	pass
