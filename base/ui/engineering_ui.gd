extends CanvasLayer
class_name EngineeringUI

signal hide_ui_called

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	set_process_input(false)
	set_process(false)
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	hide_ui_called.emit()
