extends Resource
class_name PlayerData

var total_runtime : float = 0.00
var total_num_runs : int = 0
var total_success_runs : int = 0
var total_fail_runs : int = 0

var aetherium_ore : float = 0
var promethium_shards : float = 0
var exotic_alloy : float = 0
var salvage : float = 0


#ship stats - probably will move to a sub-class of playerdata
var weapon_damage_level : int = 0
var weapon_fire_rate_level : int = 0
var max_hp_level : int = 0
var max_gun_power_level : int = 0
var max_torps_level : int = 0
var boost_efficiency_level : int = 0
var max_boost_power_level : int = 0
