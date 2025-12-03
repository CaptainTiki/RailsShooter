extends Area3D
class_name RailDockTrigger

@export var rail_id : int = 0
@export_range(-1, 1, 2) var direction : int = 1
@export_range(0.0, 100.0, 1.0)
var target_progress_percent: float = 0.0
@export var cooldown_seconds: float = 5.0

@onready var parent_room: Room = $"../.."

var _cooldown_active: bool = false


func _on_raildock_entered(area: Area3D) -> void:
	var ts := Time.get_ticks_msec()
	var level := GameManager.current_level
	var mode := level.player_root.move_mode if level and level.player_root else -1

	print("RailDock ENTER t=", ts,
		" trigger=", name, " id=", get_instance_id(),
		" area=", area.name, " area_id=", area.get_instance_id(),
		" cooldown=", _cooldown_active,
		" mode=", mode,
		" room=", parent_room.name)

	if _cooldown_active:
		print("  -> IGNORE: cooldown active")
		return

	if not area.is_in_group("player"):
		print("  -> IGNORE: area not in 'player' group (", area.name, ")")
		return

	var ship: ShipRoot = area as ShipRoot
	if ship == null:
		print("  -> IGNORE: area is not ShipRoot, is ", area.get_class())
		return

	# 🔹 START COOLDOWN *BEFORE* forwarding
	_cooldown_active = true
	monitoring = false
	print("RailDock COOLDOWN START trigger=", name, " id=", get_instance_id())

	# timer will re-enable this later
	var timer := get_tree().create_timer(cooldown_seconds)
	timer.timeout.connect(_on_cooldown_timeout)

	print("  -> FORWARDING to Level.on_raildock_trigger")
	GameManager.current_level.on_raildock_trigger(ship, self)



func _start_cooldown() -> void:
	_cooldown_active = true
	monitoring = false
	print("RailDock COOLDOWN START trigger=", name, " id=", get_instance_id())

	var timer := get_tree().create_timer(cooldown_seconds)
	timer.timeout.connect(_on_cooldown_timeout)


func _on_cooldown_timeout() -> void:
	_cooldown_active = false
	monitoring = true
	print("RailDock COOLDOWN END trigger=", name, " id=", get_instance_id())
