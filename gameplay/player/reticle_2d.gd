extends Control
class_name Reticle2D

@export var player_input: PlayerInput
@export var move_speed: float = 1200.0  # pixels per second
@export var bounds_margin: float = 32.0  # pixels from screen edge

var _screen_size: Vector2

func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	# Start at screen center
	position = _screen_size * 0.5

func _process(delta: float) -> void:
	if player_input == null:
		return

	var stick: Vector2 = player_input.virtual_stick
	var center := _screen_size * 0.5

	# Stick magnitude
	var mag := stick.length()

	if mag > 0.05:   # threshold above your deadzone
		var input_vec = Vector2(stick.x, -stick.y)   # invert Y for screen space
		position += input_vec * move_speed * delta
	else:
		# Lerp the reticle back toward the center
		position = position.lerp(center, 3.0 * delta)  # 6 fps = snappy; tune as needed

	# clamp to screen with a small margin
	var min_pos := Vector2(bounds_margin, bounds_margin)
	var max_pos := _screen_size - Vector2(bounds_margin, bounds_margin)

	position.x = clamp(position.x, min_pos.x, max_pos.x)
	position.y = clamp(position.y, min_pos.y, max_pos.y)
