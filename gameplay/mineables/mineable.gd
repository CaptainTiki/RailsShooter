extends Area3D
class_name Mineable

@onready var target_node: Targetable = $Target_Node
@onready var parent_room: Room = $"../.."
@onready var floating_progress_bar: FloatingProgressBar = $FloatingProgressBar
@onready var health: HealthComponent = $Health

var pickup_scene : PackedScene = preload("res://gameplay/pickups/resources/aetherium_pickup.tscn")
var spread : float = 0.5  # ~28 degrees
var speed : float = 10
var num_resources : int = 3

func _ready() -> void:
	parent_room.destroying_room.connect(_destroy)
	target_node.register()
	health.connect("died", _on_died)
	floating_progress_bar.set_target(self)
	floating_progress_bar.value = health.current_health
	floating_progress_bar.max_value = health.max_health
	pass

func _process(delta: float) -> void:
	if health.current_health <= health.max_health:
		floating_progress_bar.value = health.current_health
		health.current_health = clamp(health.current_health + delta, 0, health.max_health)

func adjust_damage(amount : float, _type : Globals.DamageType) -> float:
	match _type:
		Globals.DamageType.MINING:
			return amount #we take full damage from mining lazers
		_:
			return amount * 0.1 #take 1/10 damage from everything else

func take_damage(amount : float, _type : Globals.DamageType) -> void:
	health.take_damage(amount, _type)

func _on_died() -> void:
	_spawn_resource()
	_destroy()

func _spawn_resource() -> void:
	for i in num_resources:
		var drop = pickup_scene.instantiate() as Pickup
		get_parent().add_child(drop)
		var base_dir := global_transform.basis.y
		var random_offset := Vector3(
			randf_range(-spread, spread),
			0.0,
			randf_range(-spread, spread)
		)
		var dir : Vector3 = (base_dir + random_offset).normalized()
		var vel : Vector3 = dir * speed
		drop.spawn_pickup(
			vel,
			Vector3(randf() * TAU, randf()* 3, randf()* TAU),
			4,
			1.5)
		drop.global_position = global_position

func _destroy() -> void:
	target_node.unregister()
	queue_free()
