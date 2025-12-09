@tool
extends Node3D

@onready var rail_l: CSGPolygon3D = $rail_l
@onready var rail_r: CSGPolygon3D = $rail_r



func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	
	#editor only stuff
