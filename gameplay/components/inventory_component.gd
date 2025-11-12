extends Node3D
class_name InventoryComponent

@onready var inventory_canvas_layer: CanvasLayer = $InventoryCanvasLayer
@onready var bullets_grid_container: GridContainer = %BulletsGridContainer
@onready var puitems_grid_container: GridContainer = %PUItemsGridContainer

@onready var slot_zero: TextureRect = %SlotZero
@onready var slot_one: TextureRect = %SlotOne
@onready var slot_two: TextureRect = %SlotTwo
@onready var slot_three: TextureRect = %SlotThree
@onready var slot_four: TextureRect = %SlotFour
@onready var slot_five: TextureRect = %SlotFive
@onready var slot_six: TextureRect = %SlotSix
@onready var slot_seven: TextureRect = %SlotSeven

@onready var power_bar: TextureProgressBar = $InventoryCanvasLayer/Panel/MarginContainer/VBoxContainer/PowerBar
@onready var bullets_highlight: TextureRect = $InventoryCanvasLayer/BulletsHighlight
@onready var puitems_highlight: TextureRect = $InventoryCanvasLayer/PUItemsHighlight

@export var max_power : float = 8

var current_power : float = 0
var bullet_slots : Array[Dictionary]
var puitem_slots : Array[Dictionary]
var bullet_index : int = 0
var puitem_index : int = 0

const MAX_BULLET_INDEX : int = 7  #zero through 7 is 8 slots
const MAX_PUITEM_INDEX : int = 2  #zero through 2 is 3 slots

func _ready() -> void:
	inventory_canvas_layer.visible = true
	current_power = max_power
	#fill the array with empties
	for i in 8:
		var icon = bullets_grid_container.get_child(i)
		bullet_slots.append({ "icon": icon, "bullet": null })
	for i in 3:
		var icon = puitems_grid_container.get_child(i)
		puitem_slots.append({ "icon": icon, "puitem": null })
	pass

##Adds a bullet to the inventory
func add_bullet(bullet : Bullet) -> bool:
	#find first empty slot
	for i in 8:
		if not bullet_slots[i]["bullet"]:
			bullet_slots[i]["icon"].texture = bullet.icon
			bullet_slots[i]["bullet"] = bullet
			return true
	return false

##Removes a bullet from the inventory
func remove_bullet(bullet : Bullet) -> void:
	for i in 8:
		if bullet_slots[i]["bullet"] == bullet:
			bullet_slots[i]["bullet"] = null
			bullet_slots[i]["icon"].texture = null
			return

##Adds an item to the inventory
func add_item(puitem: PowerUpItem) -> bool:
	#find first empty slot
	for i in 3:
		if not puitem_slots[i]["puitem"]:
			puitem_slots[i]["icon"].texture = puitem.icon
			puitem_slots[i]["puitem"] = puitem
			return true
	return false

##Removes an item from the inventory
func remove_item(puitem: PowerUpItem) -> void:
	for i in 3:
		if puitem_slots[i]["puitem"] == puitem:
			puitem_slots[i]["puitem"] = null
			puitem_slots[i]["icon"].texture = null
			return

func use_power(value: float)-> void:
	current_power -= value
	power_bar.value = current_power

##sets the power bar current value
func set_power(value: float):
	current_power = value
	power_bar.value = value

##sets the power bar's max value
func set_max_power(max_value: float):
	max_power = max_value
	power_bar.max_value = max_value

##gets the available power from the inventory
func get_power() -> float:
	return current_power

##gets the maximum power - does not return available
func get_max_power() -> float:
	return max_power

##cycles to the next or prv bullet (dir = +1 or -1)
func cycle_bullet(dir : int) -> void:
	bullet_index += dir
	if bullet_index < 0:
		bullet_index = MAX_BULLET_INDEX
	if bullet_index > MAX_BULLET_INDEX:
		bullet_index = 0
	
	#TODO: need to skip empties on cycle_bullets
	bullets_highlight.position = bullets_grid_container.get_child(bullet_index).position

##cycles to the next or prv powerup item (dir = +1 or -1)
func cycle_puitem(dir : int) -> void:
	puitem_index += dir
	if puitem_index < 0:
		puitem_index = MAX_PUITEM_INDEX
	if puitem_index > MAX_PUITEM_INDEX:
		puitem_index = 0
		
	#TODO: need to skip empties on cycle_puitem
	puitems_highlight.position = puitems_grid_container.get_child(puitem_index).position

##Gets the bullet currently selected, if available
func get_available_bullet() -> Bullet:
	if bullet_slots[bullet_index]["bullet"].is_available():
		return bullet_slots[bullet_index]["bullet"]
	else:
		return null

func consume_selected_bullet() -> void:
	pass

func consume_selected_puitem() -> void:
	pass

##Gets the item currently selected, if available
func get_available_item() -> Item:
	if puitem_slots[puitem_index]["puitem"].is_available():
		return puitem_slots[puitem_index]["puitem"]
	else:
		return null

##Checks if the inventory already contains a bullet (used for leveling up bullets?)
func has_bullet(bullet : Bullet) -> bool:
	for i in 8:
		if bullet_slots[i]["bullet"] == bullet:
			return true
	return false

##Checks if the inventory already contains a item (used for leveling up items?)
func has_item(puitem: PowerUpItem) -> bool:
	for i in 3:
		if puitem_slots[i]["puitem"] == puitem:
			return true
	return false
