extends Area3D
class_name TriggerEvent

@onready var level: Level = $"../.."

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		level.return_to_base(true)
		pass 
