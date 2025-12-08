extends CanvasLayer
class_name EndRunMenu

@onready var container: PanelContainer = $Container
@onready var time_elapsed_value: Label = $Container/VBoxContainer/HBoxContainer/Time_Elapsed_Value
@onready var ore_collected_value: Label = $Container/VBoxContainer/HBoxContainer2/OreCollected_Value
@onready var enemies_destroyed_value: Label = $Container/VBoxContainer/HBoxContainer3/EnemiesDestroyed_Value
@onready var damage_taken_value: Label = $Container/VBoxContainer/HBoxContainer4/DamageTaken_Value

@onready var results_label: Label = $VBoxContainer/Container3/VBoxContainer/Results_Label
@onready var exit_bn: Button = $Container/VBoxContainer/Exit_Bn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_menu()

func show_menu()-> void:
	results_label.text = str(GameManager.current_level.run_outcome)
	GameManager.pause_game()
	visible = true
	GameManager.current_level.pause_menu.set_fadeout(true)
	#do some fancy "numbers go brrr" animations

func hide_menu() -> void:
	GameManager.unpause_game()
	visible = false

func _on_exit_bn_pressed() -> void:
	GameManager.set_gamestate(Globals.GameState.LOADING) #get our loading overlay
	GameManager.current_run.run_outcome = GameManager.current_level.run_outcome #tell the run we were success/failed/aborted
	#TODO: decide what stats we carry over from success / fail / abort - and do a match: here
	GameManager.current_run.time_elapsed = GameManager.current_level.elapsed_run_time #mark our time in the level
	GameManager.end_run() #this copies the data from current to persistant
	var new_menu : BaseMenu = preload("res://base/ui/base_menu.tscn").instantiate() #load our menus
	get_tree().root.add_child.call_deferred(new_menu) #now add the menus to the tree
	GameManager.current_level.destroy_level() #close out the level

func run_ended() -> void:
	show_menu() #set up the starting variables and functions
