extends Node
class_name ShipStats

signal stats_updated

@export_category("Ship Fwd Movement")
@export var lateral_speed : float = 12
@export var acceleration : float = 6.5 #6.5
@export var travel_speed : float = 44.0 #14.0
@export var brake_speed : float = 6.0
@export var boost_speed : float = 84.0 #24.0
@export var docking_speed : float = 6 #transition to docking port
@export_category("Ship Rotation")
@export var rotation_speed : float = 7 #how fast we rotate in rail & docking mode
@export var turn_speed : float = 1 #this is how fast we turn in freeflight
@export var roll_speed : float = 6
@export var max_pitch_angle : float = 0.3
@export var max_yaw_angle : float = 0.3
@export var max_roll_angle : float = 3

@export_category("Ship Weapons")
@export var max_torps : int = 6
@export var max_gun_power : int = 100



func setup_stats() -> void:
	max_torps = max_torps + GameManager.player_data.max_torps_level
	max_gun_power = max_gun_power + (GameManager.player_data.max_gun_power_level * 20)
	stats_updated.emit()
