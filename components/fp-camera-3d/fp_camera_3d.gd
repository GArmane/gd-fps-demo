@icon("res://addons/at-icons/node3d/video_camera.svg")
class_name FPCamera3D extends Node3D

enum Direction { UP = 1, DOWN = -1 }

@export_category("Settings")
@export_group("Tilt")
@export_range(-90, -60) var tilt_lower_limit := -90.0
@export_range(90, 60) var tilt_upper_limit := 90.0

@export_category("Effects")
@export_group("Tilt")
@export var enable_tilt := true

@export_category("Kick & Recoil")
@export_group("Run Tilt")
@export_range(0.0, 360.0) var run_pitch := 0.1
@export_range(0.0, 360.0) var run_roll := 0.25
@export_range(0.0, 360.0) var max_pitch := 1.0
@export_range(0.0, 360.0) var max_roll := 2.5


func update_height(
	height: float, offset: float, direction: Direction, speed: float, delta: float
) -> void:
	if position.y >= offset and position.y <= height:
		position.y = clampf(position.y + (direction * speed) * delta, offset, height)


func update_rotation(velocity: Vector3, view: Vector2) -> void:
	# Base rotation
	rotation_degrees.x += view.y
	rotation_degrees.x = clamp(rotation_degrees.x, tilt_lower_limit, tilt_upper_limit)

	# Effects
	var angles := Vector3.ZERO

	## Camera tilt
	if enable_tilt:
		var forward := global_transform.basis.z
		var right := global_transform.basis.x

		var forward_dot = velocity.dot(forward)
		var forward_tilt := clampf(
			forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch)
		)
		angles.x += forward_tilt

		var right_dot = velocity.dot(right)
		var side_tilt := clampf(
			right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll)
		)
		angles.z -= side_tilt

	%Camera3D.rotation = angles
