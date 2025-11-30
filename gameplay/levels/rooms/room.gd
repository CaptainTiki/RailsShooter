extends Node3D
class_name Room

enum RoomType {RAIL_ROOM, ARENA_ROOM}

signal destroying_room

@onready var entry_marker: Marker3D = $EntryMarker
@onready var exit_marker: Marker3D = $ExitMarker

@export var room_type : RoomType = RoomType.RAIL_ROOM

func destroy() -> void:
	destroying_room.emit() #this tells our targets to unregister
	queue_free()

func get_exit_marker() -> Marker3D:
	return exit_marker
	
func get_entry_marker() -> Marker3D:
	return entry_marker
