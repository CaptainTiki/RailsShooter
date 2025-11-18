extends Camera3D
class_name FollowCamera

@export var ship_root : ShipRoot

var camera_distance : float = 8
var camera_zoomin_distance : float = 7
var camera_zoomout_distance : float = 9
var spring_speed : float = 4

var zoom_in = false
var zoom_out = false

func _physics_process(delta: float) -> void:
	set_pos(ship_root.position)
	position.z = move_toward(position.z, camera_distance, spring_speed * delta)
	
	if zoom_in:
		position.z = move_toward(position.z, camera_zoomin_distance, 2 * spring_speed * delta)
	if zoom_out:
		position.z = move_toward(position.z, camera_zoomout_distance, 2 * spring_speed * delta)

func set_pos(pos : Vector3) -> void:
	position.x = pos.x * 0.5
	position.y = pos.y * 0.5
	pass

func set_zoom_in(zoom : bool)-> void:
	zoom_in = zoom

func set_zoom_out(zoom : bool)-> void:
	zoom_out = zoom
