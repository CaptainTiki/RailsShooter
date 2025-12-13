extends Area3D
class_name Mineable

@onready var target_node: Targetable = $Target_Node
@onready var parent_room: Room = $"../.."

var pickup_scene : PackedScene = preload("res://gameplay/pickups/resources/aetherium_pickup.tscn")
var health : float = 20
var spread : float = 0.5  # ~28 degrees
var speed : float = 10
var num_resources : int = 3

func _ready() -> void:
	parent_room.destroying_room.connect(_destroy)
	target_node.register()
	pass

func take_damage(amount : float, _type : Globals.DamageType) -> void:
		health -= amount
		print(health)
		if health <= 0:
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
