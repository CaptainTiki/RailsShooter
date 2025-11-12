extends PathFollow3D
class_name PlayerRoot

var path : Path3D
var travel_speed : float = 24.0

func _ready() -> void:
	path = get_parent()

func _physics_process(delta: float) -> void:
	progress += delta * travel_speed
