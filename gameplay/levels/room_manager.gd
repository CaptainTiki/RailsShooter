extends Node3D
class_name RoomManager

@onready var parent_level: Level = $".."

var available_rooms : Array[PackedScene] = [
		preload("res://gameplay/levels/rooms/room_rail_debug.tscn"),
		preload("res://gameplay/levels/rooms/room_arena_debug.tscn")
	]

var prev_room : Room
var current_room : Room
var next_room : Room

func spawn_new_room(num_rooms : int) -> void:
	for i in num_rooms:	
		if prev_room:
			prev_room.destroy() #get rid of the prev room before we spawn more. 
		var scene : PackedScene = get_next_room() #this grabs the next room in our run
		var new_room : Room = scene.instantiate() as Room
		add_child(new_room)
		prev_room = current_room
		current_room = next_room
		next_room = new_room
		if current_room and new_room:
			_align_rooms(current_room, new_room)

func get_next_room() -> PackedScene:
	#TODO: randomize, set up a biome picker / apply weights / etc before picking a room
	#then this can pick the next room based on our weights
	
	#return a random room in the available rooms array
	var rand_num = randi_range(0,available_rooms.size() - 1)
	return available_rooms[rand_num]

func _align_rooms(old_room : Room, new_room : Room) -> void:
	var old_room_exit : Marker3D = old_room.get_exit_marker()
	var new_room_entry : Marker3D = new_room.get_entry_marker()
	var room_rotation : Vector3 = old_room_exit.global_rotation
	new_room.global_rotation = room_rotation #rotate room first, since that will move the markers
	var offset : Vector3 = old_room_exit.global_position - new_room_entry.global_position
	new_room.global_position = offset

func get_room_path_start(room : Room) -> Vector3:
	return room.rail_path.to_global(room.rail_path.curve.get_point_position(0))

func parent_to_path(player_root : PlayerRoot)-> void:
	if current_room.room_type == Room.RoomType.RAIL_ROOM:
		current_room.rail_path.add_child(player_root)

func spawn_debug_room_after_current(scene: PackedScene) -> void:
	if next_room:
		next_room.destroy()
	
	var new_room : Room = scene.instantiate() as Room
	add_child(new_room)
	next_room = new_room
	if current_room and new_room:
		_align_rooms(current_room, new_room)
