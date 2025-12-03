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
var target_room_num : int = 4

var pending_rail_dock: RailDockTrigger = null

func _ready() -> void:
	GameManager.set_current_level(self)
	ready_first_room()
	_debug_list_rooms("level._ready()")
	level_ready.emit()
	GameManager.set_gamestate(Globals.GameState.IN_RUN)

func _debug_list_rooms(context: String) -> void:
	print("\n=== ROOM DEBUG (", context, ") ===")
	for child in get_children():
		if child is Room:
			print(" Room node: ", child.name, " id=", child.get_instance_id())
			# if Room has a room_type enum, you can also log that:
			# print("   type=", child.room_type)
	print("=== END ROOM DEBUG ===\n")

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
	_spawn_player()
	room_manager.deploy_first_room() #deploy the moon pool room
	_parent_player_to_path() #parent player to the path in moon pool room
	player_root.docking_controller.docking_position = room_manager.get_room_path_start(room_manager.current_room)
	player_root.global_position = room_manager.get_room_path_start(room_manager.current_room)

func _spawn_player() -> void:
	var player : PlayerRoot = player_scene.instantiate() as PlayerRoot #player needs to be first , so targets can register as targetable
	player.parent_level = self
	player_root = player

func on_raildock_trigger(_ship_root: ShipRoot, trigger: RailDockTrigger) -> void:
	var ts := Time.get_ticks_msec()
	print("Level.on_raildock_trigger t=", ts,
		" trigger=", trigger.name,
		" mode=", player_root.move_mode)

	match player_root.move_mode:
		PlayerRoot.MoveMode.ON_RAIL:
			print("  -> exit_rail_via_trigger")
			player_root.exit_rail_via_trigger(trigger)
		PlayerRoot.MoveMode.FREE_FLIGHT:
			print("  -> enter_rail_via_trigger")
			player_root.enter_rail_via_trigger(trigger)
		_:
			print("  -> ignored (mode=", player_root.move_mode, ")")

func _move_player_to_path() -> void:
	player_root.docking_controller.docking_position = room_manager.get_room_path_start(room_manager.current_room)
	player_root.set_move_mode(PlayerRoot.MoveMode.MOVE_TO_PATH)

func _parent_player_to_path() -> void:
	player_root.set_progress(0)
	room_manager.parent_to_path(player_root)
	player_root.set_move_mode(PlayerRoot.MoveMode.ON_RAIL)

func _parent_player_to_room() -> void:
	var ship_pos : Vector3 = player_root.ship_root.global_position
	player_root.un_parent()
	add_child(player_root) #no path, parent to the level directly
	player_root.ship_root.position = Vector3.ZERO
	player_root.global_position = ship_pos
	player_root.set_move_mode(PlayerRoot.MoveMode.FREE_FLIGHT)

#called by the player - who has exited a room (hit the end of the path, or triggered an exit node)
func _end_rail_room() -> void:
	completed_rooms += 1
	if completed_rooms >= target_room_num:
		return_to_base(true)

func _end_arena_room() -> void:
	completed_rooms += 1
	if completed_rooms >= target_room_num:
		return_to_base(true)

func return_to_base(bring_cargo : bool) -> void:
	GameManager.set_gamestate(Globals.GameState.LOADING) #get our loading overlay
	GameManager.current_run.success = bring_cargo #tell the run we were success or not
	GameManager.current_run.time_elapsed = elapsed_run_time #mark our time in the level
	GameManager.end_run(bring_cargo) #this copies the data from current to persistant
	var new_menu : BaseMenu = preload("res://base/ui/base_menu.tscn").instantiate() #load our menus
	get_tree().root.add_child.call_deferred(new_menu) #now add the menus to the tree
	queue_free() #close out the level
