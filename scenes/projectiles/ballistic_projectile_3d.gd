class_name BallisticProjectile3D extends Area3D

## Preload scene so we can instantiate it with a CollisionShape3D already created.
## Bit hacky but...oh well.
const SCENE := preload("res://scenes/projectiles/ballistic_projectile_3d.tscn")

var _resource: BallisticProjectile
var _velocity: Vector3
var _last_frame_position: Vector3


static func spawn(
	resource: BallisticProjectile,
	parent: Node3D,
	n_global_position: Vector3,
	direction: Vector3,
	muzzle_velocity: float,
) -> BallisticProjectile3D:
	var projectile := SCENE.instantiate() as BallisticProjectile3D
	projectile.initialize(resource, direction, muzzle_velocity)

	parent.add_child(projectile)
	projectile.global_position = n_global_position
	projectile.look_at(projectile.global_position + direction, Vector3.UP)

	return projectile


static func spawn_pellets(
	resource: BallisticPellets,
	parent: Node3D,
	n_global_position: Vector3,
	direction: Vector3,
	muzzle_velocity: float,
) -> Array[BallisticProjectile3D]:
	var projectiles: Array[BallisticProjectile3D]

	for i in resource.pellet_count:
		var spread_x := randf_range(-resource.base_spread_x, resource.base_spread_x)
		var spread_y := randf_range(-resource.base_spread_y, resource.base_spread_y)
		var spread = Vector3(spread_x, spread_y, 0) + direction
		var projectile := spawn(resource, parent, n_global_position, spread, muzzle_velocity)
		projectiles.append(projectile)

	return projectiles


func initialize(resource: BallisticProjectile, direction: Vector3, velocity_modifier: float):
	_resource = resource
	_velocity = direction * resource.base_velocity * velocity_modifier


func _ready():
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(_resource.lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	var space_state := get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		_last_frame_position, global_position, collision_mask
	)
	var result := space_state.intersect_ray(query)

	if result:
		global_position = result.position
		_on_body_entered(result.collider)
	else:
		_last_frame_position = global_position
		global_position += _velocity * delta


func _spawn_impact_marker(pos: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	marker.mesh = sphere

	var material := StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)

	get_tree().current_scene.add_child(marker)
	marker.global_position = pos

	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)


func _on_body_entered(_body: Node3D):
	_spawn_impact_marker(global_position)
	queue_free()
