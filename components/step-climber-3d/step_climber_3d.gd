class_name StepClimber3D extends Node3D

const STEP_HEIGHT_OFFSET := 0.05
const MIN_MOVEMENT_LEN := 0.1

@export var actor: CharacterBody3D = null


func try_step_climb(movement_vector: Vector2) -> bool:
	if actor and abs(movement_vector.length()) > MIN_MOVEMENT_LEN:
		rotation.y = atan2(-movement_vector.x, -movement_vector.y)
		if actor.is_on_wall() and actor.is_on_floor() and %WallRayCast3D.is_colliding():
			if %StepRayCast3D.is_colliding() and !%FrontRayCast3D.is_colliding():
				actor.global_position.y = (
					%StepRayCast3D.get_collision_point().y + STEP_HEIGHT_OFFSET
				)
				return true
	return false
