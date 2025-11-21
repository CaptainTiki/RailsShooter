extends Node3D
class_name CargoHold

var aetherium_ore : int = 0
var promethium_shards : int = 0
var exotic_alloy : int = 0
var salvage : int = 0

func add_cargo(a_ore : int, p_shard : int, e_alloy : int, svage : int) -> void:
	aetherium_ore += a_ore
	promethium_shards += p_shard
	exotic_alloy += e_alloy
	salvage += svage
