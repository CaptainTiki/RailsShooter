extends Node3D
class_name TargetingComponent

@export var ship_root : ShipRoot

@export_category("Aim_Assist Vars")
@export_range(-1,1) var cone_angle : float = 0.99 #dot range -1 to 1 (anything bigger than .99 is friggen huge
@export_range(50,300) var max_range : float = 100

var targets : Array[Targetable]
var current_target : Targetable

func _ready() -> void:
	targets = []

func _process(_delta: float) -> void:
	var target_to_lock : Targetable = null
	var dot_product : float = -1 #start as not null - or errors out
	var ship_forward : Vector3 = -ship_root.global_basis.z
	for tgt in targets:
		if tgt.lockable == false:
			continue #if we're not lockable - just continue the loop
		var dir_to_target : Vector3 = (tgt.global_position - ship_root.global_position)
		if dir_to_target.length() > max_range:
			continue
		dir_to_target = dir_to_target.normalized()
		var new_dot : float = ship_forward.dot(dir_to_target)
		if new_dot <= cone_angle: #outside our cone of targeting - we ignore it
			continue
		if new_dot > dot_product: #this is closer to center forward
			dot_product = new_dot
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
	#targets.remove_at(tgt)
	if tgt in targets:
		targets.erase(tgt)
	pass
