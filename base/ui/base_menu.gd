extends CanvasLayer
class_name BaseMenu

var engineering_ui : CanvasLayer
var hangar_ui : CanvasLayer
var production_ui : CanvasLayer
var command_ui : CanvasLayer
var research_ui : CanvasLayer

var current_menu : CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("BaseMenu")
	GameManager.set_gamestate(Globals.GameState.MENUS)
	_setup_menus()

func _show_menu(new_menu : CanvasLayer) -> void:
	#make sure our base menu is hidden
	self.visible = false
	self.set_process_input(false)
	
	#show the new menu (and remove any current menus)
	if current_menu:
		current_menu.visible = false
		current_menu.set_process_input(false)
		current_menu.set_process(false)
		current_menu.set_physics_process(false)
	current_menu = new_menu
	current_menu.visible = true
	current_menu.set_process_input(true)
	current_menu.set_process(true)
	current_menu.set_physics_process(true)

func _on_hide_menu() -> void:
	#show our base menu
	visible = true
	set_process_input(true)
	
	#hide the current menu
	current_menu.visible = false
	current_menu.set_process_input(false)
	current_menu.set_process(false)
	current_menu.set_physics_process(false)
	current_menu = null

func _setup_menus() -> void:
	engineering_ui = preload("uid://bwfhebxauu1mx").instantiate()
	hangar_ui = preload("uid://n7n7jb8kbhpc").instantiate()
	command_ui = preload("uid://bo7xr44ppqt17").instantiate()
	research_ui = preload("uid://bi1hphlnbn5w7").instantiate()
	production_ui = preload("uid://cj043j01prhs2").instantiate()
	
	add_child.call_deferred(engineering_ui)
	add_child.call_deferred(hangar_ui)
	add_child.call_deferred(command_ui)
	add_child.call_deferred(research_ui)
	add_child.call_deferred(production_ui)
	
	engineering_ui.connect("hide_ui_called", _on_hide_menu)
	hangar_ui.connect("hide_ui_called", _on_hide_menu)
	command_ui.connect("hide_ui_called", _on_hide_menu)
	research_ui.connect("hide_ui_called", _on_hide_menu)
	production_ui.connect("hide_ui_called", _on_hide_menu)
	
	GameManager.gamestate_changed.connect(_check_gamestate)

func _check_gamestate() -> void:
	if GameManager.game_state == Globals.GameState.IN_RUN:
		_unload_menus()

func _unload_menus() -> void:
	queue_free()

func _on_hangar_button_pressed() -> void:
	_show_menu(hangar_ui)

func _on_engineering_button_pressed() -> void:
	_show_menu(engineering_ui)

func _on_production_button_pressed() -> void:
	_show_menu(production_ui)

func _on_research_button_pressed() -> void:
	_show_menu(research_ui)

func _on_command_button_pressed() -> void:
	_show_menu(command_ui)
