extends Node3D
class_name Level

@onready var enemy_parent: Node3D = $EnemyParent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##this should fire after all the children fire - so enemies are available to go. 
	#for enemy in enemy_parent.get_children():
		#if enemy.has_method("register_as_target"):
			#enemy.register_as_target()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		#TODO: show pause screen
		var new_menu : BaseMenu = preload("res://base/ui/base_menu.tscn").instantiate()
		get_tree().root.add_child.call_deferred(new_menu)
		queue_free()
	pass
