extends Area3D
class_name RailDockTrigger

@export var rail_id : int
@export var target_progress : float
@export_range(-1,1,2) var direction : int 

@onready var parent_room: Room = $"../.."

func _on_raildock_entered(area: Area3D) -> void:
	# Filter so only the player fires this
	if not area.is_in_group("player"):
		return
		
	var ship : ShipRoot = area as ShipRoot
	if ship == null:
		return
	
	GameManager.current_level.on_raildock_exit(ship)
	
