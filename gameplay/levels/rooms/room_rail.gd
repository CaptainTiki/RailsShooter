@tool
extends Room
class_name RailRoom

@onready var rail_path: Path3D = $PathNodes/Rail_Path

@export_tool_button("Smooth curve")
var smooth_curve_button := func() -> void: _smooth_rail()

func _smooth_rail() -> void:
	if not Engine.is_editor_hint():
		return

	if rail_path == null or rail_path.curve == null:
		push_warning("RailRoom: rail_path or curve is null.")
		return

	var old_curve: Curve3D = rail_path.curve

	# Make sure the curve has baked points to sample from
	old_curve.bake_interval = 0.1

	var length := old_curve.get_baked_length()
	if length <= 0.0:
		push_warning("RailRoom: curve has zero baked length.")
		return

	var new_curve := Curve3D.new()
	var step := 0.1

	var d := 0.0
	while d <= length:
		var pos: Vector3 = old_curve.sample_baked(d)
		new_curve.add_point(pos)
		d += step

	rail_path.curve = new_curve
	print("path smoothed, length: %f, points: %d" % [length, new_curve.point_count])
