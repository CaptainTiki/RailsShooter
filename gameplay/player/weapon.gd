extends Node3D
class_name Weapon

@onready var fire_rate_timer: Timer = $FireRateTimer


var projectile_scene = preload("res://projectile.tscn")

func _process(delta: float) -> void:
	if Input.is_action_pressed("fire_primary"):
		if fire_rate_timer.is_stopped():
			fire_rate_timer.start()
			var new_projo : Projectile = projectile_scene.instantiate() as Projectile
			get_tree().get_first_node_in_group("BulletsParent").call_deferred("add_child", new_projo)
			new_projo.global_position = global_position
			new_projo.set_direction(global_transform.basis * Vector3.FORWARD)
