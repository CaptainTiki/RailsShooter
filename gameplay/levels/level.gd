extends Node3D
class_name Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		#TODO: show pause screen
		var new_menu : BaseMenu = preload("res://base/ui/base_menu.tscn").instantiate()
		get_tree().root.add_child.call_deferred(new_menu)
		queue_free()
	pass
