extends Node3D
class_name RoomManager

enum State {IN_ROOM, TRANSITIONING, SPAWNING_NEXT_ROOM, ENTERING_ROOM, EXITING_ROOM}

@onready var parent_level: Level = $".."

var deploy_room : PackedScene = preload("res://gameplay/levels/rooms/moon_bay_room.tscn")
var available_rooms : Array[PackedScene] = [
		preload("res://gameplay/levels/rooms/room_tunnel_debug.tscn")
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

func _spawn_room_for_exit(from_room: Room, from_gate: RoomGate) -> Room:
	var scene: PackedScene = get_next_room()
	var new_room: Room = scene.instantiate() as Room
	add_child(new_room)

	_ensure_room_node(from_room)
	_ensure_room_node(new_room)

	room_graph[from_room][from_gate.gate_id] = new_room
	_align_rooms(from_room, new_room, from_gate)

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

#exiting a node - this spawns in our next rooms in the graph
func _on_gate_exit(roomA: Room, gate_id) -> void:
	print("RoomManager: EXIT from ", roomA.name, " via ", gate_id)
	prev_room = roomA
	state = State.TRANSITIONING

	var gate : RoomGate = roomA.get_gate_by_id(gate_id)  # you can implement this on Room
	if gate == null:
		push_warning("RoomManager: no gate ", gate_id, " on room ", roomA.name)
		return

	# make sure exits are populated before we use them
	_populate_exits_for_room(roomA)

	var target_room: Room = gate.connected_room
	if target_room == null:
		push_warning("RoomManager: gate has no connected_room after populate?")
		return

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
	if room == null:
		return

	_ensure_room_node(room)

	for gate in room.get_room_gates():
		# Skip if this gate already knows where it goes
		if gate.connected_room:
			continue

		# 1) Spawn the neighbor
		var neighbor_scene: PackedScene = get_next_room()
		var neighbor_room: Room = neighbor_scene.instantiate() as Room
		add_child(neighbor_room)

		_ensure_room_node(neighbor_room)

		# 2) Align the neighbor to THIS gate
		_align_rooms(room, neighbor_room, gate)

		# 3) Wire A -> B
		gate.connected_room = neighbor_room
		room_graph[room][gate.gate_id] = neighbor_room

		# 4) Find the "entry" gate on neighbor and wire B -> A
		var entry_gate := _find_entry_gate_for_room(neighbor_room)
		if entry_gate:
			entry_gate.connected_room = room
			room_graph[neighbor_room][entry_gate.gate_id] = room

func _find_entry_gate_for_room(room: Room) -> RoomGate:
	var anchor: Node3D = room.get_entry_anchor()
	if anchor == null:
		return null

	var nearest_gate: RoomGate = null
	var nearest_dist := INF

	for g in room.get_room_gates():
		var d := g.global_position.distance_to(anchor.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_gate = g

	return nearest_gate

func _ensure_room_node(room: Room) -> void:
	if room == null:
		return
	if !room_graph.has(room):
		room_graph[room] = {}
