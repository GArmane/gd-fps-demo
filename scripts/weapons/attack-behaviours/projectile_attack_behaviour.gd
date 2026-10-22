class_name ProjectileAttackBehaviour extends AttackBehaviour

@export_range(0.5, 2) var velocity_modifier: float = 1.0
@export var bullet_resource: BallisticProjectile


func execute(origin: Node3D, direction: Vector3) -> void:
	var scene_tree := origin.get_tree()
	var spawn_func = (
		BallisticProjectile3D.spawn_pellets
		if is_instance_of(bullet_resource, BallisticPellets)
		else BallisticProjectile3D.spawn
	)
	(
		spawn_func
		. call(
			bullet_resource,
			scene_tree.current_scene,
			origin.global_position,
			direction,
			velocity_modifier,
		)
	)
