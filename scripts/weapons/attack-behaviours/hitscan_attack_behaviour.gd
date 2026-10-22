class_name HitscanAttackBehaviour extends AttackBehaviour

@export var max_range: float


func execute(origin: Node3D, direction: Vector3) -> void:
	var space_state = origin.get_world_3d().direct_space_state
	var from := origin.global_position
	var to: Vector3 = from + direction * max_range

	var query := PhysicsRayQueryParameters3D.create(from, to)
	var res := space_state.intersect_ray(query)

	if res:
		_spawn_impact_marker(origin, res.position)
