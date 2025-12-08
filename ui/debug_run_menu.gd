extends CanvasLayer
class_name DebugRunMenu


func _ready() -> void:
	hide_menu()

func show_menu()-> void:
	GameManager.pause_game()
	visible = true

func hide_menu() -> void:
	visible = false

func _on_exit_bn_pressed() -> void:
	hide_menu()
