@tool
extends Control

@export var radius := 30.0:
	set(value):
		assert(value, "radius should be between -360° to 360°")
		radius = value
		queue_redraw()
@export_range(0, 60) var thickness := 1.0:
	set(value):
		assert(value >= 0, "thickness should be between 0 and 60")
		thickness = value
		queue_redraw()
@export var color := Color.WHITE:
	set(value):
		color = value
		queue_redraw()
@export_range(-180.0, 180.0) var gap_angle := 45.0:
	set(value):
		assert(value >= 0 and value <= 180, "gap angle should be between -180° and 180°")
		gap_angle = value
		queue_redraw()
@export_range(0, 32) var segments := 32:
	set(value):
		assert(value >= 0, "segments should be between 0 and 32")
		segments = value
		queue_redraw()
@export var anti_aliased := true:
	set(value):
		anti_aliased = value
		queue_redraw()


func _draw():
	var gap_rad = deg_to_rad(gap_angle)
	var arc_segments = [
		# Bottom-right quadrant
		[gap_rad / 2, PI / 2 - gap_rad / 2],
		# Bottom-left quadrant
		[PI / 2 + gap_rad / 2, PI - gap_rad / 2],
		# Top-left quadrant
		[PI + gap_rad / 2, 3 * PI / 2 - gap_rad / 2],
		# Top-right quadrant
		[3 * PI / 2 + gap_rad / 2, 2 * PI - gap_rad / 2]
	]

	for arc in arc_segments:
		var start_angle = arc[0]
		var end_angle = arc[1]

		var points = []
		var angle_step = (end_angle - start_angle) / segments

		for i in range(segments + 1):
			var angle = start_angle + i * angle_step
			var point = Vector2(radius * cos(angle), radius * sin(angle))
			points.append(point)

		if points.size() > 1:
			draw_polyline(points, color, thickness, anti_aliased)
