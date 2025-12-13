extends Control
class_name Reticle2D

@export var player_input: PlayerInput

@export var move_lerp_speed: float = 10.0      # how fast we chase stick target
@export var recenter_lerp_speed: float = 5.0   # how fast we go back to center
@export var bounds_margin: float = 32.0

var _screen_size: Vector2

func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	position = _screen_size * 0.5

func _process(delta: float) -> void:
	if player_input == null:
		return

	var stick := player_input.virtual_stick
	var mag := stick.length()
	var deadzone := 0.15

	var center := _screen_size * 0.5
	var half_extents := center - Vector2(bounds_margin, bounds_margin)
	var radius : float = min(half_extents.x, half_extents.y)  # make movement area circular

	var target_pos: Vector2
	var speed: float

	if mag > deadzone:
		var input_vec := Vector2(stick.x, -stick.y)  # invert Y for screen

		# clamp to unit circle just in case
		if input_vec.length() > 1.0:
			input_vec = input_vec.normalized()

		# use SAME radius for X and Y so max deflection is a circle
		target_pos = center + input_vec * radius
		speed = move_lerp_speed
	else:
		# No input → gently recenter
		target_pos = center
		speed = recenter_lerp_speed

	var t : float = clamp(speed * delta, 0.0, 1.0)
	position = position.lerp(target_pos, t)

	# still clamp to screen, in case of weird aspect ratios
	var min_pos := Vector2(bounds_margin, bounds_margin)
	var max_pos := _screen_size - Vector2(bounds_margin, bounds_margin)

	position.x = clamp(position.x, min_pos.x, max_pos.x)
	position.y = clamp(position.y, min_pos.y, max_pos.y)
