extends Node3D
class_name PlayerShip

signal PlayerDied

@onready var ship_root : ShipRoot = $Ship_Rotation_Handler/Ship_Root
@onready var input : PlayerInput = $Player_Input
@onready var reticle : Reticle2D = $CanvasLayer/Ship_HUD/Reticle2D
@onready var controller : PlayerController = $PlayerController

var parent_level : Level

var aim_dir : Vector3 = Vector3.ZERO
var aim_point : Vector3 = Vector3.ZERO
var current_target : Targetable = null

func brake_ship(delta : float) -> void:
	controller.brake(delta)
	pass

func boost_ship(delta : float) -> void:
	controller.boost(delta)
	pass

func stop_ship() -> void:
	controller.current_speed = 0
