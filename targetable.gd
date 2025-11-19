extends Node3D
class_name Targetable

@onready var reticle: MeshInstance3D = $Target_Node/Reticle_Mesh

var targeting_component : TargetingComponent

var lockable : bool = false
var is_locked : bool = false

func ready() -> void:
	targeting_component = get_tree().get_first_node_in_group("targeting_component")

func register() -> void:
	targeting_component.register_target(self)
	pass

func unregister() -> void:
	pass

func on_locked() -> void:
	reticle.visible = true
	pass

func on_unlocked() -> void:
	reticle.visible = false
	pass
