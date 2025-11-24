extends Node3D
class_name Room

signal destroying_room

@onready var path_1: Path3D = $PathNodes/Path_1

func destroy() -> void:
	destroying_room.emit() #this tells our targets to unregister
	queue_free()
