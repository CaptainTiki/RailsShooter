extends Node3D
class_name Level

signal level_ready

@onready var enemy_parent: Node3D = $EnemyParent
@onready var room_manager: Node3D = $RoomManager

var player_scene : PackedScene = preload("res://gameplay/player/player_root.tscn")
var arena_debug_scene : PackedScene = preload("res://gameplay/levels/rooms/room_arena_debug.tscn")

var player_root: PlayerRoot
var elapsed_run_time : float = 0
var completed_rooms : int = 0
var target_room_num : int = 2

func _ready() -> void:
	GameManager.set_current_level(self)
	ready_first_room()
	level_ready.emit()
	GameManager.set_gamestate(Globals.GameState.IN_RUN)
	player_root.docking_controller.docking_complete.connect(_parent_player_to_path)
	player_root.rail_controller.path_ended.connect(_end_room)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_run_time += delta
	
	if Input.is_action_just_pressed("escape"):
		#TODO: show pause screen
		return_to_base(false) #assume this is from the pause menu and we just quit out
	if Input.is_action_just_pressed("debug_action_one"):
		GameManager.current_run.aetherium_ore += 1
		
	if Input.is_action_just_pressed("debug_win_run"):
		return_to_base(true)
	if Input.is_action_just_pressed("debug_action_two"):
		room_manager.spawn_debug_room_after_current(arena_debug_scene)
	pass

func ready_first_room() -> void:
	var player : PlayerRoot = player_scene.instantiate() as PlayerRoot #player needs to be first , so targets can register as targetable
	player.parent_level = self
	player_root = player
	room_manager.spawn_new_room(2)
	_parent_player_to_path()
	player_root.docking_controller.docking_position = room_manager.get_room_path_start(room_manager.current_room)
	player_root.global_position = room_manager.get_room_path_start(room_manager.current_room)

func ready_room(room_type : Room.RoomType)-> void:
	room_manager.spawn_new_room(1)
	#after we spawn in a new room - we'll have swapped next for currrent - so 
	#below - we need to keep checking CURRENT room - since next room is now current room
	if room_manager.current_room.room_type ==  Room.RoomType.RAIL_ROOM:
		_move_player_to_path()
	elif room_manager.current_room.room_type ==  Room.RoomType.ARENA_ROOM:
		_parent_player_to_room()

func _move_player_to_path() -> void:
	player_root.docking_controller.docking_position = room_manager.get_room_path_start(room_manager.current_room)
	player_root.set_mode(PlayerRoot.MoveMode.MOVE_TO_PATH)

func _parent_player_to_path() -> void:
	player_root.set_progress(0)
	room_manager.parent_to_path(player_root)
	player_root.set_mode(PlayerRoot.MoveMode.ON_RAIL)

func _parent_player_to_room() -> void:
	add_child(player_root) #no path, parent to the level directly
	player_root.set_mode(PlayerRoot.MoveMode.FREE_FLIGHT)

func _end_room() -> void:
	completed_rooms += 1
	if completed_rooms >= target_room_num:
		return_to_base(true)
	ready_room(room_manager.next_room.room_type)

func return_to_base(bring_cargo : bool) -> void:
	GameManager.set_gamestate(Globals.GameState.LOADING) #get our loading overlay
	GameManager.current_run.success = bring_cargo #tell the run we were success or not
	GameManager.current_run.time_elapsed = elapsed_run_time #mark our time in the level
	GameManager.end_run(bring_cargo) #this copies the data from current to persistant
	var new_menu : BaseMenu = preload("res://base/ui/base_menu.tscn").instantiate() #load our menus
	get_tree().root.add_child.call_deferred(new_menu) #now add the menus to the tree
	queue_free() #close out the level
