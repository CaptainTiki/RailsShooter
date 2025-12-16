extends Node3D
class_name AIAimComponent

@export var state_machine : AIStateMachine

@onready var host : Enemy = $"../.."
@onready var context: AIContext = $"../AIContext"

func _physics_process(delta: float) -> void:
	match state_machine.state:
		Enemy.State.OFF:
			return #early out if we're turned off
		Enemy.State.IDLE:
			do_idle(delta)
		Enemy.State.ATTACKING:
			do_attacking(delta)

func do_idle(_delta: float) -> void:
	#TODO: lerp this rotation
	if context.steering_dir.length() > 0:
		#TODO: pass UP here = so that we don't "roll". keeps us yaw only?
		host.look_at(host.global_position + context.steering_dir)
	pass

func do_attacking(_delta: float) -> void:
	if context.steering_dir.length() > 0:
		host.rotation_handle.look_at(host.global_position + context.steering_dir)
		context.aim_target_distance = (context.aim_target.global_position - global_position).length()
	pass
