extends Node3D
class_name AIAimComponent

@export var state_machine : AIStateMachine

func _process(_delta: float) -> void:
	match state_machine.state:
		Enemy.State.OFF:
			return #early out if we're turned off
