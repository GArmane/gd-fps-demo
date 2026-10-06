@icon("res://addons/at-icons/node3d/video_camera.svg")
class_name FPCamera3D extends Node3D

enum Direction { NONE = 0, UP = 1, DOWN = -1 }

@export_category("View")
@export_group("Height")
@export var max_height := 0.5
@export var min_height := 0.0
@export var ease_speed := 2.0

@export_group("View Tilt")
@export var tilt_lower_limit := -90.0
@export var tilt_upper_limit := 90.0

@export_category("Effects")
@export_group("Run tilt")
@export var enable_run_tilt := false
@export_range(0.0, 360.0) var run_pitch := 0.1
@export_range(0.0, 360.0) var run_roll := 0.25
@export_range(0.0, 360.0) var max_pitch := 1.0
@export_range(0.0, 360.0) var max_roll := 2.5

@export_group("Fall Kick")
@export var enable_fall_kick := false
@export_range(0.0, 10.0) var fall_kick_strength := 3.0
@export_range(0.1, 10.0) var fall_kick_magnitude := 0.3

@export_group("Damage kick")
@export var enable_damage_kick := false
@export var ease_damage_kick := false
@export_range(0.0, 10.0) var damage_kick_strength := 1.0
@export_range(0.1, 10.0) var damage_kick_magnitude := 0.2

@export_group("Weapon Kick")
@export var enable_weapon_kick := false
@export var weapon_kick_decay := 0.5

## Used to adjust camera height.
var _target_direction := Direction.NONE
## Used to calculate run tilt.
var _velocity := Vector3.ZERO
## Used to apply fall kick effect over time.
var _fall_kick_time_factor := 0.0
## Damage kick pitch factor.
var _damage_kick_pitch := 0.0
## Damage kick tilt factor.
var _damage_kick_roll := 0.0
## Used to apply damage kick effect over time.
var _damage_kick_time_factor := 0.0
## Used to accumulate and control weapon kick by a constant factor, instead of only by time
var _weapon_kick_angles := Vector3.ZERO


func apply_damage_kick(pitch: float, roll: float, source: Vector3) -> Vector3:
	var forward: Vector3 = global_transform.basis.z
	var right: Vector3 = global_transform.basis.x
	var direction := global_position.direction_to(source)
	_damage_kick_pitch = deg_to_rad(pitch) * direction.dot(forward) * damage_kick_strength
	_damage_kick_roll = deg_to_rad(roll) * direction.dot(right) * damage_kick_strength
	_damage_kick_time_factor = damage_kick_magnitude

	return direction


func apply_fall_kick() -> float:
	_fall_kick_time_factor = fall_kick_magnitude
	return _fall_kick_time_factor


func apply_run_tilt(velocity: Vector3) -> Vector3:
	_velocity = velocity
	return _velocity


func apply_weapon_kick(pitch: float, yaw: float, roll: float) -> Vector3:
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))
	return _weapon_kick_angles


func move_view_to(direction: Direction) -> Direction:
	_target_direction = direction
	return _target_direction


func tilt_view(vec: Vector2) -> Vector3:
	rotation_degrees.x += vec.y
	rotation_degrees.x = clamp(rotation_degrees.x, tilt_lower_limit, tilt_upper_limit)
	return rotation


func _physics_process(delta: float) -> void:
	# Height movement
	if position.y >= min_height and position.y <= max_height:
		position.y = clampf(
			position.y + (_target_direction * ease_speed) * delta, min_height, max_height
		)
	else:
		_target_direction = Direction.NONE

	# Effects
	var angles := Vector3.ZERO
	var offset := Vector3.ZERO
	## Camera tilt
	if enable_run_tilt:
		var forward := global_transform.basis.z
		var right := global_transform.basis.x

		var forward_dot = _velocity.dot(forward)
		var forward_tilt := clampf(
			forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch)
		)
		angles.x += forward_tilt

		var right_dot = _velocity.dot(right)
		var side_tilt := clampf(
			right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll)
		)
		angles.z -= side_tilt

	## Fall kick
	_fall_kick_time_factor = clampf(_fall_kick_time_factor - delta, 0.0, 10.0)
	if enable_fall_kick:
		var kick_ratio = _fall_kick_time_factor / fall_kick_magnitude
		var kick_amount = kick_ratio * deg_to_rad(fall_kick_strength)
		angles.x -= kick_amount
		offset.y -= kick_amount

	## Damage kick
	_damage_kick_time_factor = clampf(_damage_kick_time_factor - delta, 0.0, 10.0)
	if enable_damage_kick:
		var damage_ratio = _damage_kick_time_factor / damage_kick_magnitude
		if ease_damage_kick:
			damage_ratio = ease(damage_ratio, -2)
		angles.x -= damage_ratio * _damage_kick_pitch
		angles.z -= damage_ratio * _damage_kick_roll

	## Weapon kick
	if enable_weapon_kick:
		_weapon_kick_angles = _weapon_kick_angles.move_toward(
			Vector3.ZERO, weapon_kick_decay * delta
		)
		angles += _weapon_kick_angles

	%Camera3D.position = offset
	%Camera3D.rotation = angles
