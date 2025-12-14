extends Node3D
class_name AITravelProbe

@onready var ray_upleft: RayCast3D = $Probe_Handle/RayCast_UpLeft
@onready var ray_upright: RayCast3D = $Probe_Handle/RayCast_UpRight
@onready var ray_downleft: RayCast3D = $Probe_Handle/RayCast_DownLeft
@onready var ray_downright: RayCast3D = $Probe_Handle/RayCast_DownRight
@onready var ray_castback: RayCast3D = $Probe_Handle/RayCast_Back

var avoid_dir : Vector3 = Vector3.ZERO
var colliding : bool = false

func _process(_delta: float) -> void:
	calc_avoid_dir()

 #The closer to 1 - the more we need to move away in that dir 
func calc_avoid_dir() -> void:
	avoid_dir = Vector3.ZERO
	colliding = false
	
	var ul : Vector3 = check_raycast(ray_upleft)
	var ur : Vector3  = check_raycast(ray_upright)
	var dl : Vector3  = check_raycast(ray_downleft)
	var dr : Vector3  = check_raycast(ray_downright)
	var bck : Vector3  = check_raycast(ray_castback)
	
	avoid_dir = (ul+ur+dl+dr+bck).normalized()

##Returns Vector3.ZERO if no collison.
func check_raycast(ray: RayCast3D) -> Vector3:
	if not ray.is_colliding():
		return Vector3.ZERO #if we dont collide - return nothing
	
	colliding = true
	return ray.get_collision_normal()
