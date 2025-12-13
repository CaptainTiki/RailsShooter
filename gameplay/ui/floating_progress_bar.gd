extends TextureProgressBar
class_name FloatingProgressBar

var target : Node3D = null
var offset : Vector3 = Vector3.ZERO

func _ready() -> void:
	reparent(GameManager.current_level.screen_ui)
	visible = false

func _process(_delta: float) -> void:
	var camera : Camera3D = _get_camera()
	if not camera:
		visible = false
		return
	
	if value >= max_value:
		visible = false
		return
	else:
		visible = true
	
	#move to local + offset if any
	var world_pos : Vector3 = target.global_position + offset
	var screen_pos : Vector2 = camera.unproject_position(world_pos)
	global_position = screen_pos
	
	#hide if behind camera
	var local := camera.global_transform.affine_inverse() * world_pos
	if local.z > 0.0:
		visible = false
		return

#set the target for the prgress bar to be located next to in screen space
func set_target(_node3d: Node3D, _offset: Vector3 = Vector3.ZERO) -> void:
	target = _node3d
	offset = _offset

func _get_camera() -> Camera3D:
	if GameManager and GameManager.camera_rig and GameManager.camera_rig.camera:
		return GameManager.camera_rig.camera
	return null
