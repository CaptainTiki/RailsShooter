extends Room
class_name LaunchRoom

@onready var ship_spawn_location: Node3D = $ShipSpawnLocation

func get_spawn_transform() -> Transform3D:
	return ship_spawn_location.global_transform
