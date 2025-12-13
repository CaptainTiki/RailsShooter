extends Weapon
class_name BeamWeapon

enum BeamState {ON, OFF}

@export var projo_scene : PackedScene = preload("res://gameplay/projectiles/bullets/basic_bullet_proj.tscn")
@onready var fire_rate_timer: Timer = $Fire_Rate_Timer
@onready var beam_mesh: MeshInstance3D = $Rotation_Handle/Beam_Mesh
@onready var rot_handle: Node3D = $Rotation_Handle

var dmg_pr_sec : float = 4 # this is applied * delta
var damage_type : Globals.DamageType = Globals.DamageType.GENERAL
var beam_state : BeamState = BeamState.OFF
var range: float = 50

func _ready() -> void:
	set_beam_mesh(false)
	weapon_belt = Belt.SECONDARY

func _process(delta: float) -> void:
	process_beam(delta)
	
func process_beam(delta: float) -> void:
	if beam_state == BeamState.OFF:
		return
	
	var origin := global_position  # or a $Muzzle.global_position if you have it
	var target : Targetable = hub.playership.current_target  # best: use centralized aim point

	if target:
		update_beam_visual(origin, target.global_position)
	else:
		update_beam_visual(origin, origin + hub.playership.aim_dir * range)
	
	if fire_rate_timer.is_stopped():
		if try_consume_ammo():
			fire_rate_timer.start() #time is set in inspector
	else:
		if target:
			var parent = target.get_parent()
			if parent.has_method("take_damage"):
				parent.take_damage(dmg_pr_sec * delta, damage_type)

func fire_pressed() -> void:
	if beam_state == BeamState.ON:
		return
	beam_state = BeamState.ON
	fire_rate_timer.stop()
	set_beam_mesh(true)

func fire_released() -> void:
	beam_state = BeamState.OFF
	fire_rate_timer.stop()
	set_beam_mesh(false)

func set_beam_mesh(active: bool) -> void:
	beam_mesh.visible = active
	if not active:
		var s := beam_mesh.scale
		s.y = 0.001
		beam_mesh.scale = s

func update_beam_visual(origin: Vector3, target: Vector3) -> void:
	var dir := target - origin
	var dist := dir.length()
	if dist < 0.01:
		set_beam_mesh(false)
		return

	set_beam_mesh(true)

	# Put the handle halfway between origin & target
	rot_handle.global_position = origin + dir * 0.5

	var y_axis := dir / dist

	# Choose a stable perpendicular axis (avoid degeneracy when aiming straight up/down)
	var ref_up := Vector3.UP
	if abs(y_axis.dot(ref_up)) > 0.98:
		ref_up = Vector3.FORWARD

	var x_axis := ref_up.cross(y_axis).normalized()
	var z_axis := x_axis.cross(y_axis).normalized()

	# Build basis where +Y points down the beam
	rot_handle.global_basis = Basis(x_axis, y_axis, z_axis)

	# Scale the mesh so its height matches distance
	var s := beam_mesh.scale
	s.y = dist
	beam_mesh.scale = s



func try_consume_ammo() -> bool:
	if not hub.has_ammo(ammo_type, ammo_cost_per_shot): #not enough ammo to shoot
		return false
	hub.consume_ammo(ammo_type, ammo_cost_per_shot)
	return true
