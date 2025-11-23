extends Node
class_name ShipStats

signal stats_updated

var max_torps : int = 6
var max_gun_power : int = 100


func setup_stats() -> void:
	max_torps = max_torps + GameManager.player_data.max_torps_level
	max_gun_power = max_gun_power + (GameManager.player_data.max_gun_power_level * 20)
	stats_updated.emit()
