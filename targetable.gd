extends Node3D
class_name Targetable

var lockable : bool = false
var is_locked : bool = false


func register() -> void:
	pass

func unregister() -> void:
	pass

func on_locked() -> void:
	pass

func on_unlocked() -> void:
	pass
