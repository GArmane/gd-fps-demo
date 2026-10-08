class_name Player3D extends Actor3D

signal active

const FEET_ADJUSTED_HEIGHT := 0.05
const MIN_STEP_HEIGHT := 0.1
const MIN_MOVEMENT_LENGTH := 0.1
const MIN_DOT_VALUE := 0.5

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

@export_category("Step settings")
@export var step_surface_threshold := 0.3
@export var step_height: float = 0.5

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
var _step_status := "No collision"


func _process(_delta: float) -> void:
	%StateChart.set_expression_property("Is step collision:", _step_status)
	%StateChart.set_expression_property("Interaction Target", %InteractionRaycast.target)
	%StateChart.set_expression_property("Player Hitting Head", %CrouchingCheck.is_colliding())
	%StateChart.set_expression_property("Player Fall Time", _fall_time)
	%StateChart.set_expression_property("Player Velocity", velocity)
	%StateChart.set_expression_property("Player Speed", speed)


# Step climbing
func _handle_step_climbing():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if _is_vertical_surface(collision):
			var measured_height := _measure_step_height(collision)
			if (
				measured_height > MIN_STEP_HEIGHT
				and measured_height <= step_height
				and _is_valid_step_direction(collision)
			):
				global_position.y += measured_height
				_step_status = "Step found! Height: " + str(measured_height)
			else:
				_step_status = "Step too high: " + str(measured_height)
			break


func _is_vertical_surface(collision: KinematicCollision3D) -> bool:
	var normal := collision.get_normal()
	if abs(normal.y) <= step_surface_threshold:
		_step_status = "CollisionShape: Vertical Collision Found! " + str(normal)
		return true
	return _check_collision_surface(collision)


func _check_collision_surface(collision: KinematicCollision3D) -> bool:
	var space_state = get_world_3d().direct_space_state
	var collision_point = collision.get_position()

	var player_feet = _get_player_feet_position()
	collision_point.y = player_feet.y

	var query = PhysicsRayQueryParameters3D.create(player_feet, collision_point)
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]

	var result = space_state.intersect_ray(query)
	if result and abs(result.normal.y) <= step_surface_threshold:
		_step_status = "Raycast: Vertical Collision Found! " + str(result.normal)
		return true
	_step_status = "No Vertical Collision Detected."
	return false


func _get_player_feet_position() -> Vector3:
	var feet_pos = global_position
	feet_pos.y -= %StandingCollision.shape.height / 2
	feet_pos.y += FEET_ADJUSTED_HEIGHT  # small buffer
	return feet_pos


func _measure_step_height(collision: KinematicCollision3D) -> float:
	var space_state = get_world_3d().direct_space_state
	var collision_point = collision.get_position()

	var feet = _get_player_feet_position()
	var head_y = global_position.y + (%StandingCollision.shape.height / 2)

	var ray_start = Vector3(collision_point.x, head_y, collision_point.z)
	var ray_end = Vector3(collision_point.x, feet.y, collision_point.z)

	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]

	var result = space_state.intersect_ray(query)
	if result:
		return result.position.y - feet.y
	return 0.0


func _is_valid_step_direction(collision: KinematicCollision3D) -> bool:
	var normal := collision.get_normal()
	if movement_vector.length() > MIN_MOVEMENT_LENGTH:
		return movement_vector.dot(-normal) > MIN_DOT_VALUE
	return false


# Movement
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
	if is_on_floor():
		_handle_step_climbing()


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
	%FPCamera3D.offset_view_to(FPCamera3D.Direction.UP)
	%StandingCollision.disabled = false


func _on_standing_state_physics_processing(_delta: float) -> void:
	if _crouch_action.is_triggered() and is_on_floor() and not _sprint_action.is_triggered():
		%StateChart.send_event("ToCrouching")


func _on_standing_state_exited() -> void:
	%StandingCollision.disabled = true


func _on_crouching_state_entered() -> void:
	speed *= crouch_multiplier
	%CrouchingCollision.disabled = false
	%FPCamera3D.offset_view_to(FPCamera3D.Direction.DOWN)


func _on_crouching_state_physics_processing(_delta: float) -> void:
	if not _crouch_action.is_triggered() and is_on_floor() and not %CrouchingCheck.is_colliding():
		%StateChart.send_event("ToStanding")
		return


func _on_crouching_state_exited() -> void:
	speed /= crouch_multiplier
	%CrouchingCollision.disabled = true

#endregion
#endregion
