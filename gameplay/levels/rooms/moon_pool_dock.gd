extends Area3D
class_name MoonPoolDock

var armed = false

var timer : Timer

func _ready() -> void:
	get_tree().create_timer(5).connect("timeout", _arm_dock)

func _on_dock_entered(area : Area3D) -> void:
	if not armed:
		return
	
	print("area entered")
	if area.is_in_group("player"):
		if area.has_method("stop_ship"):
			area.stop_ship()
		print("returning to base")
		GameManager.current_level.end_run_successfully()

func _arm_dock() -> void:
	print("Return Dock Activated!")
	armed = true
