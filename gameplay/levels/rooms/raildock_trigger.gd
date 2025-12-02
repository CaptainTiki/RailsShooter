extends Area3D
class_name RailDockTrigger

@export var rail_id : int = 0
@export var rail : Path3D
@export_range(-1, 1, 2) var direction : int = 1  # future use

# 0 = start of path, 100 = end of path
@export_range(0.0, 100.0, 1.0)
var target_progress_percent: float = 0.0

@onready var parent_room: Room = $"../.."

func _on_raildock_entered(area: Area3D) -> void:
	if not area.is_in_group("player"):
		return

	var ship: ShipRoot = area as ShipRoot
	if ship == null:
		return
		
	print("RailDockTrigger HIT: ", name, " parent_room=", parent_room.name)
	GameManager.current_level.on_raildock_trigger(ship, self)
