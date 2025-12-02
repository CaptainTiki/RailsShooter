extends Node3D
class_name RoomManager

enum State {IN_ROOM, TRANSITIONING, SPAWNING_NEXT_ROOM, ENTERING_ROOM, EXITING_ROOM}

@onready var parent_level: Level = $".."

var deploy_room : PackedScene = preload("res://gameplay/levels/rooms/moon_bay_room.tscn")
var available_rooms : Array[PackedScene] = [
		preload("res://gameplay/levels/rooms/room_rail_debug.tscn"),
		preload("res://gameplay/levels/rooms/room_arena_debug.tscn")
	]

var room_graph = {} # { RoomA: {gate1: RoomB, gate2: RoomC, ...} }
var prev_room : Room
var current_room : Room
var next_room : Room  #room we travel toward after exiting a gate
var state : State = State.IN_ROOM

func deploy_first_room() -> void:
	var new_room : Room = deploy_room.instantiate() as Room
	add_child(new_room)
	current_room = new_room
	prev_room = null
	next_room = null
	_ensure_room_node(new_room)
	_populate_exits_for_room(new_room)

func _spawn_room_for_exit(from_room: Room, gate_id) -> Room:
	# pick a scene for the next room
	var scene: PackedScene = get_next_room()
	var new_room: Room = scene.instantiate() as Room
	add_child(new_room)

	# make sure both rooms exist in the graph
	_ensure_room_node(from_room)
	_ensure_room_node(new_room)

	# hook up the graph in the "forward" direction
	room_graph[from_room][gate_id] = new_room

	# optional: if you already know which gate in the new room connects back, you can store that later

	# align new room to from_room's exit
	if from_room:
		_align_rooms(from_room, new_room, gate_id)

	return new_room


func get_next_room() -> PackedScene:
	#TODO: randomize, set up a biome picker / apply weights / etc before picking a room
	#then this can pick the next room based on our weights
	
	#return a random room in the available rooms array
	var rand_num = randi_range(0,available_rooms.size() - 1)
	return available_rooms[rand_num]

func _align_rooms(from_room: Room, to_room: Room, from_gate: RoomGate) -> void:
	if from_room == null or to_room == null or from_gate == null:
		return

	var from_anchor: Node3D = from_gate.align_marker
	var to_anchor: Node3D = to_room.get_entry_anchor()

	# 1) Match rotation (optional but usually what we want)
	# Use the from_anchor's orientation so the new room's entry faces the right way.
	var target_basis := from_anchor.global_transform.basis
	var to_transform := to_room.global_transform
	to_transform.basis = target_basis
	to_room.global_transform = to_transform

	# 2) After rotation, recalc the to_anchor global position
	var from_pos := from_anchor.global_transform.origin
	var to_pos := to_anchor.global_transform.origin

	# 3) Compute offset and move the whole room so anchors coincide
	var offset := from_pos - to_pos
	to_room.global_position += offset


func get_room_path_start(room : Room) -> Vector3:
	return room.rail_path.to_global(room.rail_path.curve.get_point_position(0))

func parent_to_path(player_root : PlayerRoot)-> void:
	if current_room.room_type == Room.RoomType.RAIL_ROOM:
		player_root.un_parent()
		current_room.rail_path.add_child(player_root)

#func spawn_debug_room_after_current(scene: PackedScene) -> void:
	#if next_room:
		#next_room.destroy()
	#
	#var new_room : Room = scene.instantiate() as Room
	#add_child(new_room)
	#next_room = new_room
	#if current_room and new_room:
		#_align_rooms(current_room, new_room)

#exiting a node - this spawns in our next rooms in the graph
func _on_gate_exit(roomA: Room, gate_id) -> void:
	# we just left roomA through gate_id
	print("RoomManager: EXIT from ", roomA.name, " via ", gate_id)
	prev_room = roomA
	state = State.TRANSITIONING

	_ensure_room_node(roomA)

	var target_room: Room = null

	if room_graph[roomA].has(gate_id):
		# we've been through this exit before, reuse the existing room
		target_room = room_graph[roomA][gate_id]
	else:
		# first time using this exit, spawn and wire up a new room
		target_room = _spawn_room_for_exit(roomA, gate_id)

	next_room = target_room

#on entering a room - lets clean up old rooms
func _on_gate_enter(new_room: Room, gate_id) -> void:
	# we've just crossed into new_room through one of its gates
	print("RoomManager: ENTER ", new_room.name, " via ", gate_id)
	state = State.IN_ROOM

	# Shift the room pointers
	if current_room and current_room != new_room:
		prev_room = current_room

	current_room = new_room
	next_room = null

	_ensure_room_node(new_room)
	_populate_exits_for_room(new_room) 

func _populate_exits_for_room(room: Room) -> void:
	_ensure_room_node(room)

	# however you want to get its gates:
	# maybe the room has an array, or the gates are in a group.
	var gates: Array[RoomGate] = room.get_room_gates()

	for gate in gates:
		var gid = gate.gate_id

		if room_graph[room].has(gid):
			continue  # already has a linked room

		# first time we've seen this gate → spawn neighbor
		var neighbor_scene: PackedScene = get_next_room()
		var neighbor_room: Room = neighbor_scene.instantiate() as Room
		add_child(neighbor_room)

		_ensure_room_node(neighbor_room)

		room_graph[room][gid] = neighbor_room

		# optional: also hook back-link if you want proper backtracking later
		# room_graph[neighbor_room][neighbor_entry_gate] = room

		_align_rooms(room, neighbor_room, gate)


func _ensure_room_node(room: Room) -> void:
	if room == null:
		return
	if !room_graph.has(room):
		room_graph[room] = {}
