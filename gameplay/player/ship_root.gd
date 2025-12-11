extends Area3D
class_name ShipRoot

@export_category("Node Links")
@export var player_input : PlayerInput

@export_category("Movement Variables")
@export var barrel_roll_duration : float = 1.0 #in seconds
@export var num_barrel_rolls : int = 4
@export var barrel_roll_cooldown = 3.0
@export var max_engine_power = 100
@export var boost_power = 100
@export var boost_power_regen = 12
@export var boost_power_cost = 32

@onready var roll_cooldown_timer: Timer = $RollCooldown
@onready var weapon: Weapon = $Weapon
@onready var player_ship: PlayerShip = $"../.."
@onready var cargo_hold: CargoHold = $CargoHold

@onready var cargo_ammount_label: Label = %cargo_ammount_label

@onready var ship_stats: ShipStats = %ShipStats
@onready var shields_component: SheildsComponent = $Shields
@onready var armor_component: ArmorComponent = $Armor
@onready var health_component: HealthComponent = $Health

var camera : CameraRig

var roll_tween : Tween #used for barrel rolls
var is_rolling : bool = false

func _ready() -> void:
	ship_stats.setup_stats()
	camera = GameManager.camera_rig
	player_input.roll_left.connect(roll_left)
	player_input.roll_right.connect(roll_right)

func _process(delta: float) -> void:
	if Input.is_action_pressed("fire_primary"):
		weapon.fire_guns()
	if Input.is_action_pressed("fire_secondary"):
		weapon.fire_torp()
	
	if Input.is_action_pressed("brake"):
		if boost_power > boost_power_cost:
			boost_power -= boost_power_cost * delta
			player_ship.brake_ship()
	if Input.is_action_pressed("boost"):
		if boost_power > boost_power_cost:
			boost_power -= boost_power_cost * delta
			player_ship.boost_ship()
	
	if Input.is_action_just_released("brake"):
		camera.zoom_in = false
	if Input.is_action_just_released("boost"):
		camera.zoom_out = false
		
	boost_power = min(max_engine_power, boost_power + boost_power_regen * delta)

func roll_left() -> void:
	if roll_cooldown_timer.is_stopped():
		#TODO: set invul flags here
		is_rolling = true
		var rotate_target = (rotation.z + (num_barrel_rolls * PI)) * 1
		roll_tween = create_tween()
		roll_tween.tween_property(self, "rotation:z", rotate_target, barrel_roll_duration)
		roll_tween.connect("finished", finish_roll)
		roll_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func roll_right() -> void:
	if roll_cooldown_timer.is_stopped():
		#TODO: set invul flags here
		var rotate_target = (rotation.z + (num_barrel_rolls * PI)) * -1
		roll_tween = create_tween()
		roll_tween.tween_property(self, "rotation:z", rotate_target, barrel_roll_duration)
		roll_tween.connect("finished", finish_roll)
		roll_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func finish_roll() -> void:
	#TODO: unset invul flags here
	roll_cooldown_timer.start()
	is_rolling = false
	rotation.z = 0

func add_cargo(a_ore : int, p_shard : int, e_alloy : int, svage : int) -> void:
	cargo_hold.add_cargo(a_ore, p_shard, e_alloy, svage)
	cargo_ammount_label.text = str(cargo_hold.aetherium_ore + cargo_hold.promethium_shards + cargo_hold.exotic_alloy + cargo_hold.salvage)
