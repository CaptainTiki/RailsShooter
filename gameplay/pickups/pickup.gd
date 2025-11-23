extends Node3D
class_name Pickup

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var velocity : Vector3 = Vector3.ZERO
var rotation_speed : Vector3 = Vector3.ZERO
var gravity : float = 0.01
var drag : float = 14.0

var lifetime : float = 20.0
var spawning : bool = true
var falling : bool = false
var settling : bool = false
var settle_loc : Vector3 = Vector3.ZERO
var settled : bool = false

func _ready() -> void:
	ray_cast_3d.collision_mask = 17

func spawn_pickup(vel : Vector3, rot : Vector3, grav : float = 0.01, drg : float = 14.0) -> void:
	velocity = vel
	rotation_speed = rot
	gravity = grav
	drag = drg

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		free_pickup()
	
	if settled:
		return
	
	mesh_instance_3d.rotation += rotation_speed * delta
	
	if spawning:
		velocity = velocity.move_toward(Vector3.ZERO, drag * delta)
		velocity += Vector3(0,-gravity * delta,0) #apply gravity
		global_position += velocity * delta
		if velocity.y <= 0:
			spawning = false
			get_tree().create_timer(0.25).timeout.connect(_pause_falling)
	elif falling:
		velocity = velocity.move_toward(Vector3.ZERO, drag * delta)
		velocity += Vector3(0,-gravity * delta,0) #apply gravity
		global_position += velocity * delta
		if velocity.y <0 and ray_cast_3d.is_colliding():
			var collision := ray_cast_3d.get_collider()
			if "terrain" in collision.get_groups():
				settle_loc = ray_cast_3d.get_collision_point()
				rotation_speed = Vector3.ZERO
				falling = false
				settling = true
	elif settling:
		global_position = global_position.move_toward(settle_loc, gravity * delta)
		rotation_speed = rotation_speed.move_toward(Vector3.ZERO, delta)
		if (global_position - settle_loc).length() <= 0.1:
			velocity = Vector3.ZERO
			rotation_speed = Vector3.ZERO
			settling = false
			settled = true

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		free_pickup()

func _pause_falling() -> void:
	falling = true

func free_pickup() -> void:
	queue_free()
