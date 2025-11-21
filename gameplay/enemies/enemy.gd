extends Node3D
class_name Enemy

@onready var health: HealthComponent = $Health
@onready var target_node: ShipTarget = $Target_Node

var pickup_scene : PackedScene = preload("res://gameplay/pickups/ship-ammo/torp_ammo_pickup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.connect("died", _on_died)
	target_node.register()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func register_as_target() -> void:
	target_node.register()
	pass

func _on_died() -> void:
	var drop = pickup_scene.instantiate() as Pickup
	get_parent().add_child(drop)
	drop.global_position = global_position
	target_node.unregister()
	queue_free()
