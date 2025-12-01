extends CanvasLayer
class_name CommandUI

signal hide_ui_called

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	set_process_input(false)
	set_process(false)
	set_physics_process(false)

func _on_button_pressed() -> void:
	hide_ui_called.emit()
