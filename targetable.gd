extends Node3D
class_name Targetable

@onready var reticle: MeshInstance3D = $Reticle_Mesh

var targeting_component : TargetingComponent

var lockable : bool = true
var is_locked : bool = false

func _ready() -> void:
	reticle.visible = false
	GameManager.current_level.level_ready.connect(_register_with_tgt_comp)
	pass

func register() -> void:
	targeting_component.register_target(self)
	pass

func unregister() -> void:
	targeting_component.unregister_target(self)
	pass

func lock_target() -> void:
	if reticle:
		reticle.visible = true
	pass

func unlock_target() -> void:
	if reticle:
		reticle.visible = false
	pass

func _register_with_tgt_comp() -> void:
	targeting_component = get_tree().get_first_node_in_group("targeting_component")
	register()
