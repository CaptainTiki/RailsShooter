extends Node3D
class_name Level


signal level_ready
signal run_complete(success: bool)

@onready var enemy_parent: Node3D = $EnemyParent
@onready var room_manager: Node3D = $RoomManager

@onready var level_ui: Node = $Level_UI
@onready var screen_ui: Control = $Level_UI/Screen_UI
@onready var vignette_fade: TextureRect = $Level_UI/Faders/Vignette_Fade
@onready var screen_fade: ColorRect = $Level_UI/Faders/Screen_Fade

var player_scene : PackedScene = preload("res://gameplay/player/player_ship.tscn")
var arena_debug_scene : PackedScene = preload("res://gameplay/levels/rooms/room_arena_debug.tscn")
var pause_scene : PackedScene = preload("res://ui/pause_menu.tscn")
var endrun_scene : PackedScene = preload("uid://cojyl2glcbth2")
var debug_scene : PackedScene = preload("res://ui/debug_run_menu.tscn")

var pause_menu : PauseMenu = null
var endrun_menu : EndRunMenu = null
var debugrun_menu : DebugRunMenu = null

var run_outcome : RunData.RunOutcome = RunData.RunOutcome.NOT_LOGGED
var player_ship: PlayerShip
var elapsed_run_time : float = 0
var completed_rooms : int = 0
var target_room_num : int = 4

@export var end_run_cinematic_timer : float = 5

func _ready() -> void:
	GameManager.set_current_level(self)
	ready_first_room()
	_debug_list_rooms("level._ready()")
	level_ready.emit()
	GameManager.set_gamestate(Globals.GameState.IN_RUN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player_ship.PlayerDied.connect(_on_player_died)
	_setup_menus()

func _debug_list_rooms(context: String) -> void:
	print("\n=== ROOM DEBUG (", context, ") ===")
	for child in get_children():
		if child is Room:
			print(" Room node: ", child.name, " id=", child.get_instance_id())
			# if Room has a room_type enum, you can also log that:
			# print("   type=", child.room_type)
	print("=== END ROOM DEBUG ===\n")

func _process(delta: float) -> void:
	if GameManager.game_state == Globals.GameState.IN_RUN:
		elapsed_run_time += delta
	
	if Input.is_action_just_pressed("escape"):
		print("pause menu show")
		pause_menu.show_menu()
	if Input.is_action_just_pressed("debug_action_one"):
		GameManager.current_run.aetherium_ore += 1
		
	if Input.is_action_just_pressed("debug_win_run"):
		_end_run_successfully()
	if Input.is_action_just_pressed("debug_action_two"):
		room_manager.spawn_debug_room_after_current(arena_debug_scene)
	pass

func ready_first_room() -> void:
	_spawn_player()
	room_manager.deploy_first_room() #deploy the moon pool room
	#TODO: make an explicit spawn ship in moonpool room
	if room_manager.current_room.has_method("get_spawn_transform"):
		player_ship.global_transform = room_manager.current_room.get_spawn_transform()
	else:
		player_ship.global_position = Vector3.ZERO

func _spawn_player() -> void:
	var player : PlayerShip = player_scene.instantiate() as PlayerShip #player needs to be first , so targets can register as targetable
	player.parent_level = self
	player_ship = player
	add_child(player) 

func _end_room() -> void:
	completed_rooms += 1
	if completed_rooms >= target_room_num:
		_end_run_successfully()

func _end_run_successfully() -> void:
	run_outcome = RunData.RunOutcome.SUCCESS
	run_complete.emit(true) #we made it!!  - let everybody know
	#TODO: animate camera to circle ship?
	#TODO: do some other celebratory yay stuff
	get_tree().create_timer(end_run_cinematic_timer).connect("timeout", _end_run) #now we show end game screen

func abort_run() -> void:
	#player has aborted- skip the cinematic flair - we're bailing
	run_outcome = RunData.RunOutcome.ABORTED
	run_complete.emit(false) #we aborted / died - let everybody know
	_end_run()

func _end_run()-> void:
	endrun_menu.show_menu()

func _on_player_died() -> void:
	run_outcome = RunData.RunOutcome.FAILED
	run_complete.emit(false) #we aborted / died - let everybody know
	#TODO: shift camera back some
	#TODO: fade lighting - go red? - drop a vignette that closes in?
	get_tree().create_timer(end_run_cinematic_timer).connect("timeout", _end_run) #now we show end game screen


func _setup_menus() -> void:
	pause_menu = pause_scene.instantiate() as PauseMenu
	endrun_menu = endrun_scene.instantiate() as EndRunMenu
	debugrun_menu = debug_scene.instantiate() as DebugRunMenu
	level_ui.add_child(pause_menu)
	level_ui.add_child(endrun_menu)
	level_ui.add_child(debugrun_menu)
	pause_menu.hide()
	endrun_menu.hide()
	debugrun_menu.hide()

func show_debug_menu() -> void:
	debugrun_menu.show_menu()

func destroy_level() -> void:
	#do any thing we need before we free the level here
	queue_free()
