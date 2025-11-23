extends Node

var game_state : Globals.GameState = Globals.GameState.LOADING

var current_run : RunData = null
var last_run : RunData = null
var player_data : PlayerData = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_run = RunData.new()
	player_data = PlayerData.new()


func set_gamestate(gs : Globals.GameState)-> void:
	#do any other work to change gamestates here
	game_state = gs

func start_run() -> void:
	current_run = RunData.new()

func end_run(is_success : bool) -> void:
	
	#TODO: set up all the data change from a run into persistant player_data
	#TODO: set up transfer / copy functions inside player_data, so this doesn't turn into 1000 lines 
	player_data.aetherium_ore += current_run.aetherium_ore
	player_data.promethium_shards += current_run.promethium_shards
	player_data.exotic_alloy += current_run.exotic_alloy
	player_data.salvage += current_run.salvage
	player_data.total_num_runs += 1
	
	if current_run.success:
		player_data.total_success_runs += 1
	else:
		player_data.total_fail_runs += 1
	
	set_gamestate(Globals.GameState.MENUS)
	last_run = current_run #store the last run so you can go back and look if you want
