extends Node
class_name ShipStats

signal stats_updated

@export_category("Ship Fwd Movement")
@export var travel_speed : float = 64.0    # max forward speed
@export var brake_speed : float = 6.0
@export var boost_speed : float = 44.0
@export var docking_speed : float = 6.0
@export var throttle_change_speed : float = 8.0  # how fast throttle ramps (units/s)
@export var reverse_factor : float = 0.25        # 25% of forward speed as max reverse

@export_category("Ship Rotation")
@export var turn_speed : float = 0.65 #this is how fast we turn in freeflight
@export var pitch_turn_bonus : float = 1.3 #how much extra turn when we're pitched over. 
@export var roll_speed : float = 6
@export var max_pitch_angle : float = 1.5
@export var max_roll_angle : float = 1.3

@export_category("Ship Weapons")
@export var max_torps : int = 6
@export var max_gun_power : int = 100

func setup_stats() -> void:
	max_torps = max_torps + GameManager.player_data.max_torps_level
	max_gun_power = max_gun_power + (GameManager.player_data.max_gun_power_level * 20)
	stats_updated.emit()
