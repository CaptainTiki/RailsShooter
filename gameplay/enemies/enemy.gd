extends Node3D
class_name Enemy

@onready var health: HealthComponent = $Health
@onready var target_node: ShipTarget = $Target_Node
@onready var parent_room: Room = $"../.."

var pickup_scene : PackedScene = preload("res://gameplay/pickups/ship-ammo/torp_ammo_pickup.tscn")
var spread : float = 0.5  # ~28 degrees
var speed : float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_room.destroying_room.connect(_destroy)
	health.connect("died", _on_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_died() -> void:
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
	target_node.unregister()
	queue_free()

func _destroy() -> void:
	target_node.unregister()
	queue_free()
