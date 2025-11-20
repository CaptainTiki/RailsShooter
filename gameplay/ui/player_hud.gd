extends Node3D


@onready var guns_power_bar: ProgressBar = $Hud_SubViewport/HUD_root/MarginContainer/LeftDock/HBoxContainer/Guns_PowerBar
@onready var torps_ammo_bar: ProgressBar = $Hud_SubViewport/HUD_root/MarginContainer/LeftDock/HBoxContainer/Torps_AmmoBar

@onready var health_bar: ProgressBar = $Hud_SubViewport/HUD_root/MarginContainer/RightDock/HBoxContainer/Health_Bar
@onready var shields_bar: ProgressBar = $Hud_SubViewport/HUD_root/MarginContainer/RightDock/HBoxContainer/Shields_Bar

@onready var boost_power_bar_left: ProgressBar = $Hud_SubViewport/HUD_root/MarginContainer/BottomDock/HBoxContainer/Boost_PowerBar_Left
@onready var boost_power_bar_right: ProgressBar = $Hud_SubViewport/HUD_root/MarginContainer/BottomDock/HBoxContainer/Boost_PowerBar_Right

@onready var health: HealthComponent = $"../Health"
@onready var shields: SheildsComponent = $"../Shields"


@onready var hud_sub_viewport: SubViewport = $Hud_SubViewport
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@onready var weapon: Weapon = %Weapon


func _ready() -> void:
	var material : StandardMaterial3D = mesh_instance_3d.mesh.surface_get_material(0)
	material.albedo_texture = hud_sub_viewport.get_texture()
	
	_setup_UI()

func _process(_delta: float) -> void:
	_update_weapon_UI()
	_update_ship_UI()

func _update_weapon_UI() -> void:
	guns_power_bar.value = weapon.current_power
	torps_ammo_bar.value = weapon.current_torps
	pass

func _update_ship_UI() -> void:
	health_bar.value = health.current_health
	shields_bar.value = shields.current_shields

func _setup_UI() -> void:
	guns_power_bar.max_value = weapon.max_power
	torps_ammo_bar.max_value = weapon.max_torps
	health_bar.max_value = health.max_health
	shields_bar.max_value = shields.max_shield
	guns_power_bar.value = weapon.current_power
	torps_ammo_bar.value = weapon.current_torps
	health_bar.value = health.current_health
	shields_bar.value = shields.current_shields
