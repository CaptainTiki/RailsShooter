extends Area3D
class_name Bullet

var icon : Texture2D = preload("res://assets/ui/kenney_ui-pack-space-expansion/PNG/Extra/Double/panel_glass_notches.png")
var direction : Vector3
var available: bool = false

#these need exported for the database lookup in bullet_manager
@export var damage: float = 0.1
@export var speed: float = 0.1
@export var rarity: Globals.Rarity = Globals.Rarity.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(damage: float, velocity: Vector3, owner: Node) -> void:
	available = false
	pass

func is_available() -> bool:
	return available

func destroy() -> void:
	pass
