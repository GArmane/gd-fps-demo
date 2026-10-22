@abstract
@icon("res://addons/at-icons/node/bullseye.svg")
class_name AttackBehaviour extends Resource

@abstract func execute(origin: Node3D, direction: Vector3) -> void


func _spawn_impact_marker(origin: Marker3D, pos: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	marker.mesh = sphere

	var material := StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)

	var scene_tree := origin.get_tree()
	scene_tree.current_scene.add_child(marker)
	marker.global_position = pos

	scene_tree.create_timer(2.0).timeout.connect(marker.queue_free)
