class_name PlayerController extends CharacterBody3D

@export_category("Movement settings")
@export var acceleration := 1.0
@export var friction := 1.0
@export var speed := 6.0
@export var jump_velocity = 4.5


func _physics_process(delta: float) -> void:
	# Handle rotation.
	var mouse_rotation: Vector2 = %MouseCapture.input
	rotation_degrees.y += mouse_rotation.x
	%CameraController.update_rotation(mouse_rotation)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Handle movement.
	# Apply lerp on a Vector2 and then update player velocity, so it prevents the issue
	# of X and Z reaching 0 at different times.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_vec = Vector2(velocity.x, velocity.z)
	move_vec = (
		lerp(move_vec, Vector2(direction.x, direction.z) * speed, acceleration)
		if direction
		else move_vec.move_toward(Vector2.ZERO, friction)
	)

	velocity = Vector3(move_vec.x, velocity.y, move_vec.y)
	move_and_slide()
