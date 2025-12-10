extends Node3D
class_name TargetingComponent

@export var ship_root : ShipRoot
@export var camera : FollowCamera
@export var reticle_ui: Control

@export_category("Aim_Assist Vars")
@export_range(-1,1) var cone_angle : float = 0.999 #dot range -1 to 1 (anything bigger than .99 is friggen huge
@export_range(50,300) var max_range : float = 100

var targets: Array[Targetable]
var current_target: Targetable

func _ready() -> void:
	targets = []

func _process(_delta: float) -> void:
	if camera == null:
		return

	var space_state := get_world_3d().direct_space_state

	# 1) Get reticle screen position
	var viewport_rect := get_viewport().get_visible_rect()
	var reticle_screen_pos: Vector2 = viewport_rect.size * 0.5
	if reticle_ui:
		reticle_screen_pos = reticle_ui.get_global_position()

	# 2) Build aim ray from camera through reticle
	var aim_origin: Vector3 = camera.project_ray_origin(reticle_screen_pos)
	var aim_dir: Vector3    = camera.project_ray_normal(reticle_screen_pos).normalized()

	var target_to_lock: Targetable = null
	var best_dot: float = -1.0

	for tgt in targets:
		if not tgt.lockable:
			continue

		var to_target: Vector3 = tgt.global_position - aim_origin
		var dist: float = to_target.length()
		if dist > max_range:
			continue

		to_target = to_target.normalized()
		var new_dot: float = aim_dir.dot(to_target)
		if new_dot <= cone_angle:
			continue

		if new_dot > best_dot:
			best_dot = new_dot
			target_to_lock = tgt
	
	if target_to_lock == null:
		if current_target:
			current_target.unlock_target()
			current_target = null
	
	#once we're through the list - we're left with the target_to_lock being the closest targetable
	if target_to_lock != current_target:
		if current_target:
			current_target.unlock_target()
		if target_to_lock:
			target_to_lock.lock_target()
		
		current_target = target_to_lock

func register_target(tgt : Targetable) -> void:
	targets.append(tgt)
	pass

func unregister_target(tgt : Targetable) -> void:
	if tgt in targets:
		targets.erase(tgt)
	pass

func debug_dot_to_deg(dot: float) -> float:
	dot = clamp(dot, -1.0, 1.0) # safety
	return rad_to_deg(acos(dot))
