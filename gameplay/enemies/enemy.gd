extends Node3D
class_name Enemy

enum State {OFF, STUNNED, ATTACKING, IDLE}

@onready var health: HealthComponent = $Health
@onready var target_node: ShipTarget = $Target_Node
@onready var parent_room: Room = $"../.."
@onready var floating_progress_bar: FloatingProgressBar = $FloatingProgressBar

@onready var ai_aim_component: AIAimComponent = $AI_Brain/AiAimComponent
@onready var ai_move_component: Node3D = $AI_Brain/AIMoveComponent
@onready var ai_state_machine: AIStateMachine = $AI_Brain/AiStateMachine
@onready var rotation_handle: Node3D = $Rotation_Handle

var pickup_scene : PackedScene = preload("res://gameplay/pickups/ship-ammo/torp_ammo_pickup.tscn")
var drop_spread : float = 0.5  # ~28 degrees
var drop_speed : float = 5

var movement_speed : float = 5
var attack_speed : float = 25
var acceleration : float = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_room.destroying_room.connect(_destroy)
	health.connect("died", _on_died)
	target_node.register()
	floating_progress_bar.set_target(self)
	floating_progress_bar.value = health.current_health
	floating_progress_bar.max_value = health.max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	floating_progress_bar.value = health.current_health

func _on_died() -> void:
	var drop = pickup_scene.instantiate() as Pickup
	get_parent().add_child(drop)
	var base_dir := global_transform.basis.y
	var random_offset := Vector3(
		randf_range(-drop_spread, drop_spread),
		0.0,
		randf_range(-drop_spread, drop_spread)
	)
	var dir : Vector3 = (base_dir + random_offset).normalized()
	var vel : Vector3 = dir * drop_speed
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

func adjust_damage(amount : float, _type : Globals.DamageType) -> float:
	match _type:
		Globals.DamageType.MINING:
			return amount * 0.1 #we take 1/10 damage from mining lazers
		_:
			return amount #take full damage from everything else

func take_damage(amount : float, _type : Globals.DamageType) -> void:
	health.take_damage(amount, _type)
