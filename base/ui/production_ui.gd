extends CanvasLayer
class_name ProductionUI

signal hide_ui_called

@onready var a_ammount_label: Label = %A_Ammount_Label
@onready var p_ammount_label: Label = %P_Ammount_Label
@onready var e_ammount_label: Label = %E_Ammount_Label
@onready var s_ammount_label: Label = %S_Ammount_Label

@onready var w_dmg_lvl_label: Label = %w_dmg_lvl_label
@onready var w_fr_lvl_label: Label = %w_fr_lvl_label
@onready var max_hp_lvl_label: Label = %max_hp_lvl_label
@onready var max_ammo_lvl_label: Label = %max_ammo_lvl_label
@onready var max_torps_lvl_label: Label = %max_torps_lvl_label
@onready var bst_efcy_lvl_label: Label = %bst_efcy_lvl_label
@onready var mx_bst_pwr_lvl_label: Label = %mx_bst_pwr_lvl_label

@onready var w_dmg_bn: Button = %w_dmg_bn
@onready var w_fr_bn: Button = %w_fr_bn
@onready var max_hp_bn: Button = %max_hp_bn
@onready var max_ammo_bn: Button = %max_ammo_bn
@onready var max_torps_bn: Button = %max_torps_bn
@onready var bst_efcy_bn: Button = %bst_efcy_bn
@onready var mx_bst_pwr_bn: Button = %mx_bst_pwr_bn


var player_data : PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_data = GameManager.player_data
	_setup_ui()
	_refresh_data()

func _refresh_data() -> void:
	a_ammount_label.text = str(player_data.aetherium_ore)
	p_ammount_label.text = str(player_data.aetherium_ore)
	e_ammount_label.text = str(player_data.aetherium_ore)
	s_ammount_label.text = str(player_data.aetherium_ore)
	
	w_dmg_lvl_label.text = "lvl " + str(player_data.weapon_damage_level)
	w_fr_lvl_label.text = "lvl " + str(player_data.weapon_fire_rate_level)
	max_hp_lvl_label.text = "lvl " + str(player_data.max_hp_level)
	max_ammo_lvl_label.text = "lvl " + str(player_data.max_gun_power_level)
	max_torps_lvl_label.text = "lvl " + str(player_data.max_torps_level)
	bst_efcy_lvl_label.text = "lvl " + str(player_data.boost_efficiency_level)
	mx_bst_pwr_lvl_label.text = "lvl " + str(player_data.max_boost_power_level)

func _setup_ui() -> void:
	visible = false
	set_process_input(false)
	set_process(false)
	set_physics_process(false)

#exit menu
func _on_button_pressed() -> void:
	hide_ui_called.emit()


func _on_w_dmg_bn_pressed() -> void:
	#TODO: hook up cost into data - instead of hardcode here
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.weapon_damage_level += 1
	_refresh_data()
	
func _on_w_fr_bn_pressed() -> void:
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.weapon_fire_rate_level += 1
	_refresh_data()
	
func _on_max_hp_bn_pressed() -> void:
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.max_hp_level += 1
	_refresh_data()
	
func _on_max_ammo_bn_pressed() -> void:
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.max_gun_power_level += 1
	_refresh_data()
	
func _on_max_torps_bn_pressed() -> void:
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.max_torps_level += 1
	_refresh_data()
	
func _on_bst_efcy_bn_pressed() -> void:
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.boost_efficiency_level += 1
	_refresh_data()
	
func _on_mx_bst_pwr_bn_pressed() -> void:
	if player_data.aetherium_ore >= 2:
		player_data.aetherium_ore -= 2
		player_data.max_boost_power_level += 1
	_refresh_data()
