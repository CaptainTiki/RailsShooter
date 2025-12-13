extends Node3D
class_name Weaponhub

signal primary_weapon_changed(new_weapon: Weapon)
signal secondary_weapon_changed(new_weapon: Weapon)

@export var playership : PlayerShip
@export var stats : ShipStats
@export var reticle_ui: Control

@onready var targeting_component: TargetingComponent = $"../TargetingComponent"
var bullet_parent: Node3D 

var primary_weaps : Array[Weapon]
var secondary_weaps : Array[Weapon]

var current_primary_index : int = 0
var current_secondary_index : int = 0

var ammo_bullet_sm : float = 25
var ammo_bullet_lg : float = 0
var ammo_rocket : float = 0
var ammo_explosive : float = 0
var ammo_energy : float = 250

var camera_rig : CameraRig

func _ready() -> void:
	camera_rig = GameManager.camera_rig
	bullet_parent = GameManager.current_level.get_node("BulletParent")
	if bullet_parent == null:
		print("ahhhhh")
	
	for child in get_children():
		if child is Weapon:
			if child.weapon_belt == Weapon.Belt.PRIMARY:
				if not primary_weaps.has(child):
					primary_weaps.append(child)
			elif child.weapon_belt == Weapon.Belt.SECONDARY:
				if not secondary_weaps.has(child):
					secondary_weaps.append(child)
	primary_weapon_changed.emit(primary_weaps[current_primary_index])
	secondary_weapon_changed.emit(primary_weaps[current_secondary_index])

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cycle_primary_weapon"):
		cycle_primary_weapon()
	if Input.is_action_just_pressed("cycle_secondary_weapon"):
		cycle_secondary_weapon()

#we only support forward cycling - not enough buttons on the controller lol
func cycle_primary_weapon() -> void:
	if primary_weaps.is_empty():
		return
	current_primary_index = (current_primary_index + 1) % primary_weaps.size()
	primary_weapon_changed.emit(primary_weaps[current_primary_index])
	print("Primary Weapon changed to: ", primary_weaps[current_primary_index])

#we only support forward cycling - not enough buttons on the controller lol
func cycle_secondary_weapon() -> void:
	if secondary_weaps.is_empty():
		return
	current_secondary_index = (current_secondary_index + 1) % secondary_weaps.size()
	secondary_weapon_changed.emit(secondary_weaps[current_secondary_index])
	print("Secondary Weapon changed to: ", secondary_weaps[current_secondary_index])

func fire_primary_pressed() -> void:
	if primary_weaps.is_empty():
		return
	primary_weaps[current_primary_index].fire_pressed()

func fire_primary_released() -> void:
	if primary_weaps.is_empty():
		return
	primary_weaps[current_primary_index].fire_released()

func fire_secondary_pressed() -> void:
	if secondary_weaps.is_empty():
		return
	secondary_weaps[current_secondary_index].fire_pressed()

func fire_secondary_released() -> void:
	if secondary_weaps.is_empty():
		return
	secondary_weaps[current_secondary_index].fire_released()

func has_ammo(ammo_type: Globals.AmmoType, cost: float) -> bool:
	return get_ammo(ammo_type) >= cost

func consume_ammo(ammo_type: Globals.AmmoType, cost: float) -> bool:
	if not has_ammo(ammo_type, cost):
		return false
	change_ammo(ammo_type, get_ammo(ammo_type) - cost)
	return true

func get_ammo(ammo_type : Globals.AmmoType) -> float:
	match ammo_type:
		Globals.AmmoType.ENERGY:
			return ammo_energy
		Globals.AmmoType.BULLET_SM:
			return ammo_bullet_sm
		Globals.AmmoType.BULLET_LG:
			return ammo_bullet_lg
		Globals.AmmoType.ROCKET:
			return ammo_rocket
		Globals.AmmoType.EXPLOSIVE:
			return ammo_explosive
		_:
			return 0

## This can add or subtract ammo - if the add_ammount is pos or neg
func change_ammo(ammo_type : Globals.AmmoType, amt : float) -> void:
	match ammo_type:
		Globals.AmmoType.ENERGY:
			ammo_energy = clamp(ammo_energy + amt, 0, stats.max_ammo_energy)
		Globals.AmmoType.BULLET_SM:
			ammo_bullet_sm = clamp(ammo_bullet_sm + amt, 0, stats.max_ammo_bullet_sm)
		Globals.AmmoType.BULLET_LG:
			ammo_bullet_lg = clamp(ammo_bullet_lg + amt, 0, stats.max_ammo_bullet_lg)
		Globals.AmmoType.ROCKET:
			ammo_rocket = clamp(ammo_rocket + amt, 0, stats.max_ammo_rocket)
		Globals.AmmoType.EXPLOSIVE:
			ammo_explosive = clamp(ammo_explosive + amt, 0, stats.max_ammo_explosive)

func refill_all_ammo() -> void: #for debug and return to base, or run start
	ammo_energy = stats.max_ammo_energy
	ammo_bullet_sm = stats.max_ammo_bullet_sm
	ammo_bullet_lg = stats.max_ammo_bullet_lg
	ammo_rocket = stats.max_ammo_rocket
	ammo_explosive = stats.max_ammo_explosive
