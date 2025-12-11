extends CanvasLayer

@onready var build_version: Label = $Control/BuildVersion

func _ready() -> void:
	var game_version : String = ProjectSettings.get("application/config/version")
	build_version.text = "Build: " + str(game_version)
