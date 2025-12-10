extends Node3D
class_name PlayerShip

signal PlayerDied

@onready var ship_root : ShipRoot = $Ship_Rotation_Handler/Ship_Root
@onready var camera : FollowCamera = $Ship_Rotation_Handler/FollowCamera
@onready var input : PlayerInput = $Ship_Rotation_Handler/FollowCamera/Player_Input
@onready var reticle : Reticle2D = $CanvasLayer/Ship_HUD/Reticle2D

var parent_level : Level

var aim_dir : Vector3 = Vector3.ZERO
