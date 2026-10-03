class_name Player extends CharacterBody3D

signal active

@export_category("Camera settings")
@export var camera_default_height := 0.5
@export var camera_crouching_offset := 0.0
@export var camera_speed := 3.0

@export_category("Movement settings")
@export var acceleration := 1.0
@export var friction := 1.0
@export var speed := 4.8
@export var crouch_multiplier := 0.4
@export var sprinting_multiplier := 1.25
@export var jump_velocity = 4.5

@export_category("Input Actions")
@export var _move_action: GUIDEAction
@export var _crouch_action: GUIDEAction
@export var _jump_action: GUIDEAction
@export var _sprint_action: GUIDEAction

var movement_vector: Vector3:
	get():
		var input_dir := _move_action.value_axis_2d
		return transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()


func _process(_delta: float) -> void:
	%StateChart.set_expression_property("Player Hitting Head", %CrouchingCheck.is_colliding())
	%StateChart.set_expression_property("Player Velocity", velocity)


func _update_movement(delta: float, direction := Vector3.ZERO) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if _jump_action.is_triggered() and is_on_floor():
		velocity.y = jump_velocity

	# Handle movement.
	# Apply lerp on a Vector2 and then update player velocity, so it prevents the issue
	# of X and Z reaching 0 at different times.
	var move_vec = Vector2(velocity.x, velocity.z)
	move_vec = (
		lerp(move_vec, Vector2(direction.x, direction.z) * speed, acceleration)
		if direction
		else move_vec.move_toward(Vector2.ZERO, friction)
	)

	velocity = Vector3(move_vec.x, velocity.y, move_vec.y)
	move_and_slide()


func _update_rotation() -> void:
	var mouse_rotation: Vector2 = %MouseCapture.input
	rotation_degrees.y += mouse_rotation.x
	%Camera.update_rotation(mouse_rotation)


#region State machine
func _on_root_state_entered() -> void:
	active.emit()


# Movement
func _on_idle_state_physics_processing(delta: float) -> void:
	if _move_action.is_triggered() and _move_action.value_axis_2d != Vector2.ZERO:
		%StateChart.send_event("Moving")
		return

	_update_rotation()
	_update_movement(delta)


func _on_walking_state_physics_processing(delta: float) -> void:
	if not _move_action.is_triggered() or _move_action.value_axis_2d == Vector2.ZERO:
		%StateChart.send_event("Idle")
		return
	if _sprint_action.is_triggered():
		%StateChart.send_event("Sprinting")
		return

	_update_rotation()
	_update_movement(delta, movement_vector)


func _on_sprinting_state_entered() -> void:
	speed *= sprinting_multiplier


func _on_sprinting_state_exited() -> void:
	speed /= sprinting_multiplier


func _on_sprinting_state_physics_processing(delta: float) -> void:
	if not _sprint_action.is_triggered():
		%StateChart.send_event("Walking")
		return

	_update_rotation()
	_update_movement(delta, movement_vector)


# Posture
func _on_standing_state_entered() -> void:
	%StandingCollision.disabled = false


func _on_standing_state_exited() -> void:
	%StandingCollision.disabled = true


func _on_standing_state_physics_processing(delta: float) -> void:
	%Camera.update_height(
		camera_default_height, camera_crouching_offset, Camera.Direction.UP, camera_speed, delta
	)
	if _crouch_action.is_triggered() and is_on_floor():
		%StateChart.send_event("Crouch")


func _on_crouching_state_entered() -> void:
	speed *= crouch_multiplier
	%CrouchingCollision.disabled = false


func _on_crouching_state_exited() -> void:
	speed /= crouch_multiplier
	%CrouchingCollision.disabled = true


func _on_crouching_state_physics_processing(delta: float) -> void:
	if not _crouch_action.is_triggered() and is_on_floor() and not %CrouchingCheck.is_colliding():
		%StateChart.send_event("Stand")
		return
	%Camera.update_height(
		camera_default_height, camera_crouching_offset, Camera.Direction.DOWN, camera_speed, delta
	)

#endregion
