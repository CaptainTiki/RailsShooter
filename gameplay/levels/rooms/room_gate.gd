extends Area3D
class_name RoomGate

signal gate_entered(room_ref, gate_id)
signal gate_left(room_ref, gate_id)

@export var gate_id: StringName = "gate_1"
@export var align_marker : Marker3D
@onready var parent_room: Room = $"../.."  # as you had it


func _on_roomgate_entered(area: Area3D) -> void:
	# Filter so only the player fires this
	if not (area.is_in_group("player") and area is ShipRoot):
		return

	var rm = GameManager.current_level.room_manager
	if rm == null:
		return

	# If current_room == this gate's parent_room → we are LEAVING this room
	if rm.current_room == parent_room:
		print("Gate LEFT: ", parent_room.name, " via ", gate_id)
		gate_left.emit(parent_room, gate_id)
		rm._on_gate_exit(parent_room, gate_id)
	else:
		# Otherwise, we are ENTERING this room through this gate
		print("Gate ENTERED: ", parent_room.name, " via ", gate_id)
		gate_entered.emit(parent_room, gate_id)
		rm._on_gate_enter(parent_room, gate_id)
