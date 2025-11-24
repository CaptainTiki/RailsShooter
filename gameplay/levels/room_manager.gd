extends Node3D
class_name RoomManager

@onready var parent_level: Level = $".."

var available_rooms : Array[PackedScene] = [
		preload("res://gameplay/levels/rooms/room.tscn")
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

func get_next_room() -> PackedScene:
	#TODO: randomize, set up a biome picker / apply weights / etc before picking a room
	#then this can pick the next room based on our weights
	
	#return a random room in the available rooms array
	var rand_num = randi_range(0,available_rooms.size() - 1)
	return available_rooms[rand_num]

func get_next_path_start() -> Vector3:
	return next_room.path_1.curve.get_point_position(0)

func parent_to_path(player_root : PlayerRoot)-> void:
	current_room.path_1.add_child(player_root)
