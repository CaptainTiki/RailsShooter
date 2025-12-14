extends Node3D
class_name AIStateMachine

signal state_changed(new_state : Enemy.State)

@export var player_detection_range : float = 40

@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var context: AIContext = $"../AIContext"
@onready var ray: RayCast3D = $RayCast3D

var state : Enemy.State = Enemy.State.OFF

func _ready() -> void:
	state = Enemy.State.IDLE
	ray.target_position.z = -player_detection_range
	#TODO: change the size of the area3d sphere - based on our "player_detection_range"

func _process(_delta: float) -> void:
	match state:
		Enemy.State.OFF:
			return #early out if we're turned off
		Enemy.State.IDLE:
			do_idle()
		Enemy.State.ATTACKING:
			do_attacking()
			return


func do_idle() -> void:
	if not context.aim_target:
		return
	
	ray.look_at(context.aim_target.global_position)
	if not ray.is_colliding():
		return #no collision - we're out of range
	
	if not ray.get_collider().is_in_group("player"):
		return #not player / might be a wall

	set_state(Enemy.State.ATTACKING)

func do_attacking() -> void:
	#TODO: if we loose target - set a timer - then return back "home" if we don't re-connect with player
	pass

func set_state(new_state : Enemy.State) -> void:
	state = new_state
	state_changed.emit(state)

func _on_playerdetector_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		context.aim_target = area
		pass

func _on_playerdetector_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		#TODO: have the enemy go to the last known location and "search" for the player
		#then you can have the enemy 'return home'
		pass
