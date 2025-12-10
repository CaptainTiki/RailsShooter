extends Control
class_name VirtualStickVisualization

@export var player_input: PlayerInput
@export var show_debug: bool = true
@export var alpha: float = 0.3  # 30% opacity

func _process(_delta: float) -> void:
	# redraw every frame while enabled
	if visible and show_debug:
		queue_redraw()

func _draw() -> void:
	if not show_debug:
		return
	if player_input == null:
		return

	# only show in "mouse mode"
	if player_input.gamepad:
		return

	var center: Vector2 = player_input.input_center
	var half_extents: Vector2 = player_input.input_half_extents
	var mouse_pos: Vector2 = player_input.mouse_pos

	# deadzone radius in screen space:
	var deadzone_radius: float = player_input.deadzone_prcnt * min(half_extents.x, half_extents.y)

	var col := Color(1.0, 1.0, 1.0, alpha)

	# draw deadzone circle
	if deadzone_radius > 0.0:
		draw_circle(center, deadzone_radius, col)

	# draw line from center to mouse
	draw_line(center, mouse_pos, col, 2.0)
