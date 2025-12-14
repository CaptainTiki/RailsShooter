extends BeamWeapon
class_name MiningLazer

func _ready() -> void:
	display_name = "MiningLazer"
	damage_type = Globals.DamageType.MINING
	dmg_pr_sec = 25
	set_beam_mesh(false)
	weapon_belt = Belt.SECONDARY
