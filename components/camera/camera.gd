class_name Camera extends Node3D

enum Direction { UP = 1, DOWN = -1 }

@export_category("Camera Settings")
@export_group("Tilt")
@export_range(-90, -60) var tilt_lower_limit := -90.0
@export_range(90, 60) var tilt_upper_limit := 90.0


func update_height(
	height: float, offset: float, direction: Direction, speed: float, delta: float
) -> void:
	if position.y >= offset and position.y <= height:
		position.y = clampf(position.y + (direction * speed) * delta, offset, height)


func update_rotation(vec: Vector2) -> Vector3:
	rotation_degrees.x += vec.y
	rotation_degrees.x = clamp(rotation_degrees.x, tilt_lower_limit, tilt_upper_limit)
	return rotation_degrees
