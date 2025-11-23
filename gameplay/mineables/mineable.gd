extends Area3D
class_name Mineable

@onready var target_node: Targetable = $Target_Node

var pickup_scene : PackedScene = preload("res://gameplay/pickups/resources/aetherium_pickup.tscn")
var spread : float = 0.5  # ~28 degrees
var speed : float = 10

func _ready() -> void:
	target_node.register()

func _on_area_entered(area: Area3D) -> void:
		if area.is_in_group("bullet"):
			if area is Projectile:
				_spawn_resource()
				target_node.unregister()
				queue_free()

func _spawn_resource() -> void:
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
