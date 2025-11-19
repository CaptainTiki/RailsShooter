extends Node3D
class_name TargetingComponent

@export_category("Aim_Assist Vars")
@export_range(-1,1) var cone_angle : float = 1 #dot range -1 to 1
@export_range(50,300) var max_range : float = 100

var targets : Array[Targetable]
var current_target : Targetable

func _ready() -> void:
	targets = []

func register_target(tgt : Targetable) -> void:
	targets.append(tgt)
	pass

func unregister_target(tgt : Targetable) -> void:
	#targets.remove_at(tgt)
	if tgt in targets:
		targets.erase(tgt)
	pass
