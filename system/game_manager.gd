extends Node

signal gamestate_changed
signal run_ended

var game_state : Globals.GameState = Globals.GameState.LOADING

var current_level : Level = null
var camera_rig : CameraRig = null

var current_run : RunData = null
var last_run : RunData = null
var player_data : PlayerData = null

var level_scene : PackedScene = preload("res://gameplay/levels/debug_level.tscn")
var camera_scene : PackedScene = preload("res://gameplay/player/camera_rig.tscn")
var build_overlay_scene : PackedScene = preload("uid://bfut641ooya4n")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_run = RunData.new()
	player_data = PlayerData.new()
	camera_rig = camera_scene.instantiate()
	add_child(camera_rig)
	setup_buildoverlay()

func set_current_level(lvl : Level)-> void:
	current_level = lvl

func set_gamestate(gs : Globals.GameState)-> void:
	#do any other work to change gamestates here
	game_state = gs
	gamestate_changed.emit()

func start_run() -> void:
	current_run = RunData.new()
	get_tree().change_scene_to_packed(level_scene)

func end_run() -> void:
	player_data.total_num_runs += 1
	
	#TODO: set up all the data change from a run into persistant player_data
	#TODO: set up transfer / copy functions inside player_data, so this doesn't turn into 1000 lines 
	
	if current_run.run_outcome == RunData.RunOutcome.SUCCESS:
		player_data.total_success_runs += 1
		player_data.aetherium_ore += current_run.aetherium_ore
		player_data.promethium_shards += current_run.promethium_shards
		player_data.exotic_alloy += current_run.exotic_alloy
		player_data.salvage += current_run.salvage
	elif current_run.run_outcome == RunData.RunOutcome.FAILED:
		player_data.total_fail_runs += 1
	elif current_run.run_outcome == RunData.RunOutcome.ABORTED:
		player_data.total_aborted_runs += 1
	
	set_gamestate(Globals.GameState.MENUS)
	unpause_game() #just in case we're still paused when we get back to the menus
	last_run = current_run #store the last run so you can go back and look if you want

func pause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func unpause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func setup_buildoverlay()-> void:
	var overlay = build_overlay_scene.instantiate()
	add_child(overlay)
	pass
