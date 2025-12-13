extends CanvasLayer
class_name PauseMenu

@onready var resume_bn: Button = $Container/VBoxContainer/Resume_Bn
@onready var exit_bn: Button = $Container/VBoxContainer/Exit_Bn
@onready var debug_bn: Button = $Container/VBoxContainer/Debug_Bn

@onready var container: PanelContainer = $Container

var vignette : TextureRect
var fade : ColorRect
var fade_speed: float = 1.5
var fadeout : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vignette = GameManager.current_level.vignette_fade
	fade = GameManager.current_level.screen_fade
	debug_bn.visible = false
	debug_bn.disabled = true
	hide_menu()

func _process(delta: float) -> void:
	if Input.is_action_pressed("debug_action_one"):
		debug_bn.visible = true
		debug_bn.disabled = false
	else:
		debug_bn.visible = false
		debug_bn.disabled = true
	
	if fadeout:
		vignette.self_modulate.a += fade_speed * 2 * delta
		fade.self_modulate.a += fade_speed * delta

func show_menu()-> void:
	GameManager.pause_game()
	visible = true
	set_fadeout(true)

func hide_menu() -> void:
	GameManager.unpause_game()
	visible = false

func _on_resume_bn_pressed() -> void:
	vignette.self_modulate.a = 0
	fade.self_modulate.a = 0
	hide_menu()

func _on_exit_bn_pressed() -> void:
	visible = false #don't unpause the game
	GameManager.current_level.abort_run()

func _on_debug_bn_pressed() -> void:
	GameManager.current_level.show_debug_menu()

func set_fadeout(active : bool) -> void:
	fadeout = active
