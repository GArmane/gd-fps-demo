class_name Player3D extends Actor3D

signal active

@export_category("Camera settings")
## After this much time, triggers camera kick effect.
@export var camera_fall_kick_threshold := 0.4

@export_category("Movement settings")
@export_range(0.0, 1.0) var acceleration := 0.2
@export var friction := 50
@export var speed := 4.8
@export var crouch_multiplier := 0.4
@export var sprinting_multiplier := 1.25
@export var jump_velocity = 5

@export_category("Input Actions")
@export var _move_action: GUIDEAction
@export var _fire_action: GUIDEAction
@export var _crouch_action: GUIDEAction
@export var _jump_action: GUIDEAction
@export var _sprint_action: GUIDEAction

var movement_vector: Vector3:
	get():
		var input_dir := _move_action.value_axis_2d
		return transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()

## Store the amount of time the player has been falling.
var _fall_time := 0.0


func _process(_delta: float) -> void:
	%StateChart.set_expression_property("Interaction Target", %InteractionRaycast.target)
	%StateChart.set_expression_property("Player Fall Time", _fall_time)
	%StateChart.set_expression_property("Player Hitting Head", %CrouchingCheck.is_colliding())
	%StateChart.set_expression_property("Player Velocity", velocity)
	%StateChart.set_expression_property("Player Speed", speed)


func _update_movement(delta: float, direction := Vector3.ZERO) -> void:
	# Rotate character and camera
	var view_pos = %MouseCapture.relative_position
	rotation_degrees.y += view_pos.x
	%FPCamera3D.tilt_view(view_pos)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle movement.
	# Apply lerp on a Vector2 and then update player velocity, so it prevents the issue
	# of X and Z reaching 0 at different times.
	var move_vec = Vector2(velocity.x, velocity.z)
	move_vec = (
		lerp(move_vec, Vector2(direction.x, direction.z) * speed, acceleration)
		if direction
		else move_vec.move_toward(Vector2.ZERO, friction * delta)
	)

	velocity = Vector3(move_vec.x, velocity.y, move_vec.y)
	move_and_slide()


#region State machine
func _on_root_state_entered() -> void:
	active.emit()


#region Combat
func _on_combat_state_processing(_delta: float) -> void:
	if _fire_action.is_triggered():
		%FPCamera3D.apply_weapon_kick(1, 1, 1)


#endregion


#region Movement
func _on_grounded_state_physics_processing(_delta: float) -> void:
	if not is_on_floor():
		%StateChart.send_event("ToAirborne")
		return


func _on_grounded_state_processing(_delta: float) -> void:
	if _jump_action.is_triggered():
		%StateChart.send_event("ToAirborne")
		return


func _on_idle_state_physics_processing(delta: float) -> void:
	if _move_action.is_triggered() and _move_action.value_axis_2d != Vector2.ZERO:
		%StateChart.send_event("ToWalking")
		return

	_update_movement(delta)


func _on_walking_state_physics_processing(delta: float) -> void:
	if not _move_action.is_triggered() or _move_action.value_axis_2d == Vector2.ZERO:
		%StateChart.send_event("ToIdle")
		return
	if _sprint_action.is_triggered():
		%StateChart.send_event("ToSprinting")
		return

	_update_movement(delta, movement_vector)


func _on_sprinting_state_entered() -> void:
	speed *= sprinting_multiplier
	%StateChart.send_event("ToStanding")


func _on_sprinting_state_physics_processing(delta: float) -> void:
	if not _sprint_action.is_triggered():
		%StateChart.send_event("ToWalking")
		return

	_update_movement(delta, movement_vector * sprinting_multiplier)


func _on_sprinting_state_exited() -> void:
	speed /= sprinting_multiplier


func _on_airborne_state_entered() -> void:
	if is_on_floor():
		%StateChart.send_event("ToJumping")
	else:
		%StateChart.send_event("ToFalling")


func _on_falling_state_entered() -> void:
	_fall_time = 0.0


func _on_falling_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		%StateChart.send_event("ToGrounded")
	_fall_time += delta
	_update_movement(delta, movement_vector)


func _on_falling_state_exited() -> void:
	if _fall_time >= camera_fall_kick_threshold:
		%FPCamera3D.apply_fall_kick()


func _on_jumping_state_entered() -> void:
	velocity.y = jump_velocity


func _on_jumping_state_physics_processing(delta: float) -> void:
	if velocity.y <= 0:
		%StateChart.send_event("ToFalling")
	_update_movement(delta, movement_vector)


#endregion


#region Posture
func _on_standing_state_entered() -> void:
	%FPCamera3D.move_view_to(FPCamera3D.Direction.UP)
	%StandingCollision.disabled = false


func _on_standing_state_physics_processing(_delta: float) -> void:
	if _crouch_action.is_triggered() and is_on_floor() and not _sprint_action.is_triggered():
		%StateChart.send_event("ToCrouching")


func _on_standing_state_exited() -> void:
	%StandingCollision.disabled = true


func _on_crouching_state_entered() -> void:
	speed *= crouch_multiplier
	%CrouchingCollision.disabled = false
	%FPCamera3D.move_view_to(FPCamera3D.Direction.DOWN)


func _on_crouching_state_physics_processing(_delta: float) -> void:
	if not _crouch_action.is_triggered() and is_on_floor() and not %CrouchingCheck.is_colliding():
		%StateChart.send_event("ToStanding")
		return


func _on_crouching_state_exited() -> void:
	speed /= crouch_multiplier
	%CrouchingCollision.disabled = true

#endregion
#endregion
