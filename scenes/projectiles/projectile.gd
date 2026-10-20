class_name Projectile3D extends Area3D

const DEFAULT_LIFETIME = 3.0

var velocity: Vector3
var damage: float
var lifetime: float = DEFAULT_LIFETIME

var _last_frame_position: Vector3


func setup(n_velocity: Vector3, n_damage: float, n_lifetime = DEFAULT_LIFETIME) -> Projectile3D:
	velocity = n_velocity
	damage = n_damage
	lifetime = n_lifetime
	_last_frame_position = global_position

	return self


func _ready():
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


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


func _physics_process(delta: float) -> void:
	var space_state := get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(_last_frame_position, global_position)
	var result := space_state.intersect_ray(query)

	if result:
		global_position = result.position
		_on_body_entered(result.collider)
	else:
		_last_frame_position = global_position
		global_position += velocity * delta


func _on_body_entered(_body: Node3D):
	_spawn_impact_marker(global_position)
	queue_free()
