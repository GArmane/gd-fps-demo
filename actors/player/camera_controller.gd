class_name CameraController extends Node3D

@export var debug: bool = false
@export_category("Camera Settings")
@export_group("Tilt")
@export_range(-90, -60) var tilt_lower_limit: float = -90
@export_range(90, 60) var tilt_upper_limit: float = 90


func update_rotation(vec: Vector2) -> Vector3:
	rotation_degrees.x += vec.y
	rotation_degrees.x = clamp(rotation_degrees.x, tilt_lower_limit, tilt_upper_limit)
	return rotation_degrees
