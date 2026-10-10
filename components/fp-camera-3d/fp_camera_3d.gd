@tool
@icon("res://addons/at-icons/node3d/video_camera.svg")
class_name FPCamera3D extends Node3D

enum Posture { CROUCHING, STANDING }

const MIN_SCREEN_SHAKE := 0.05
const MAX_SCREEN_SHAKE := 0.5

@export_category("View")
@export_group("Height")
@export var standing_height := 1.5
@export var crouching_height := 1.0
@export var ease_speed := 2.0

@export_group("View Tilt")
@export var tilt_lower_limit := -90.0
@export var tilt_upper_limit := 90.0

@export_category("Effects")
@export var observer: CharacterBody3D = null:
	set(value):
		observer = value
		update_configuration_warnings()
@export_group("Run tilt")
@export var enable_run_tilt := false:
	set(value):
		enable_run_tilt = value
		update_configuration_warnings()
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

@export_group("Screen Shake")
@export var enable_screen_shake := false

@export_group("Headbob")
@export var enable_headbob := false:
	set(value):
		enable_headbob = value
		update_configuration_warnings()
@export_range(0.0, 0.1, 0.001) var headbob_pitch := 0.05
@export_range(0.0, 0.1, 0.001) var headbob_roll := 0.025
@export_range(0.0, 0.04, 0.001) var headbob_up := 0.005
@export_range(3.0, 8.0, 0.1) var headbob_frequency := 6.0
@export_range(0.1, 1.0, 0.1) var headbob_magnitude := 0.5

## Used to adjust camera height.
var _desired_height := standing_height
## Used to apply fall kick effect over time.
var _fall_kick_time_factor := 0.0
## Damage kick pitch factor.
var _damage_kick_pitch := 0.0
## Damage kick tilt factor.
var _damage_kick_roll := 0.0
## Used to apply damage kick effect over time.
var _damage_kick_time_factor := 0.0
## Used to accumulate and control weapon kick by a constant factor, instead of only by time.
var _weapon_kick_angles := Vector3.ZERO
## Used to control frequency of screen shake.
var _screen_shake_tween: Tween = null
## Used to control frequency of headbobing steps.
var _step_time_factor := 0.0


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


func apply_screen_shake(amount: float, seconds: float) -> Tween:
	if _screen_shake_tween:
		_screen_shake_tween.kill()

	_screen_shake_tween = create_tween()
	_screen_shake_tween.tween_method(_update_screen_shake.bind(amount), 0.0, 1.0, seconds).set_ease(
		Tween.EASE_OUT
	)

	return _screen_shake_tween


func apply_weapon_kick(pitch: float, yaw: float, roll: float) -> Vector3:
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))
	return _weapon_kick_angles


func offset_view_to(posture: Posture) -> float:
	_desired_height = crouching_height if posture == Posture.CROUCHING else standing_height
	return _desired_height


func tilt_view(vec: Vector2) -> Vector3:
	rotation_degrees.x += vec.y
	rotation_degrees.x = clamp(rotation_degrees.x, tilt_lower_limit, tilt_upper_limit)
	return rotation


func _update_screen_shake(alpha: float, amount: float) -> void:
	if not enable_screen_shake:
		return

	amount = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE)
	var current_amount := amount * (1.0 - alpha)
	%Camera3D.h_offset = randf_range(-current_amount, current_amount)
	%Camera3D.v_offset = randf_range(-current_amount, current_amount)


#region Engine callbacks
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Height movement
	position.y = move_toward(position.y, _desired_height, ease_speed * delta)

	# Effects
	var angles := Vector3.ZERO
	var offset := Vector3.ZERO
	## Camera tilt
	if enable_run_tilt and observer:
		var forward := global_transform.basis.z
		var right := global_transform.basis.x

		var forward_dot = observer.velocity.dot(forward)
		var forward_tilt := clampf(
			forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch)
		)
		angles.x += forward_tilt

		var right_dot = observer.velocity.dot(right)
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

	## Headbob
	if enable_headbob and observer:
		var speed = Vector2(observer.velocity.x, observer.velocity.z).length()
		if speed > 0.1 and observer.is_on_floor():
			_step_time_factor += delta * (speed / headbob_frequency)
			_step_time_factor = fmod(_step_time_factor, 1.0)
		else:
			_step_time_factor = 0.0
		var headbob_sin = sin(_step_time_factor * 2.0 * PI) * headbob_magnitude

		angles.x -= headbob_sin * deg_to_rad(headbob_pitch) * speed
		angles.z -= headbob_sin * deg_to_rad(headbob_roll) * speed
		offset.y += headbob_sin * headbob_up * speed

	%Camera3D.position = offset
	%Camera3D.rotation = angles


#endregion


#region Editor callbacks
func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if enable_run_tilt and not observer:
		warnings.push_back("Observer must be set for run tilt effect.")
	if enable_headbob and not observer:
		warnings.push_back("Observer must be set for headbob effect.")

	return warnings
#endregion
