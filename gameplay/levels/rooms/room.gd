extends Node3D
class_name Room

enum RoomType {NONE, TUNNEL_ROOM, ARENA_ROOM}

signal destroying_room

@onready var entry_marker: Marker3D = $Markers/EntryMarker
@onready var exit_marker: Marker3D = $Markers/ExitMarker
@onready var markers: Node3D = $Markers
@onready var triggers: Node3D = $Triggers
@export var room_type : RoomType = RoomType.TUNNEL_ROOM


func _ready() -> void:
	print("Room READY: ", name, " id=", get_instance_id())
	
func destroy() -> void:
	destroying_room.emit() #this tells our targets to unregister
	queue_free()

func get_room_gates() -> Array[RoomGate]:
	var room_gates : Array[RoomGate]
	for gate in triggers.get_children():
		if gate is RoomGate:
			room_gates.append(gate)
	return room_gates

func get_gate_by_id(id : String) -> RoomGate:
	for gate in triggers.get_children():
		if gate is RoomGate:
			if gate.gate_id == id:
				return gate
	return null

func get_entry_anchor() -> Marker3D:
	var first_marker : Marker3D = markers.get_child(0)
	return first_marker
