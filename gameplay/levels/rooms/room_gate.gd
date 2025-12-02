extends Area3D
class_name RoomGate

signal gate_entered(room_ref, gate_id)
signal gate_left(room_ref, gate_id)

@export var gate_id: StringName = &"gate_1"
@export var align_marker: Node3D

@onready var parent_room: Room = $"../.."
var connected_room: Room = null


func _on_roomgate_entered(area: Area3D) -> void:
	if not (area.is_in_group("player") and area is ShipRoot):
		return

	var rm = GameManager.current_level.room_manager
	if rm == null:
		return

	# LEAVING: only if this is the current room and we are "in a room"
	if rm.current_room == parent_room and rm.state == RoomManager.State.IN_ROOM:
		print("Gate LEFT: ", parent_room.name, " via ", gate_id)
		gate_left.emit(parent_room, gate_id)
		rm._on_gate_exit(parent_room, gate_id)
		return

	# ENTERING: only if we're transitioning and THIS room is the chosen next_room
	if rm.state == RoomManager.State.TRANSITIONING and rm.next_room == parent_room:
		print("Gate ENTERED: ", parent_room.name, " via ", gate_id)
		gate_entered.emit(parent_room, gate_id)
		rm._on_gate_enter(parent_room, gate_id)
		return
