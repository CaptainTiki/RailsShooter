extends CanvasLayer
class_name HangarUI

signal hide_ui_called
signal level_loaded

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	set_process_input(false)
	set_process(false)
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_backbn_pressed() -> void:
	hide_ui_called.emit()

func _on_launchbn_pressed() -> void:
	#TODO: need to load from a list of levels
	GameManager.set_gamestate(Globals.GameState.LOADING)
	GameManager.start_run()
	level_loaded.emit()
