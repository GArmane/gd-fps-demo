@abstract
@icon("res://addons/at-icons/node/bullseye.svg")
class_name AttackBehaviour extends Resource

@export var damage: float
@export var sounds: Array[AudioStream] = []
# TODO abstract attack rate into a behaviour or configurable state chart?
@export var attack_rate: float:
	set(value):
		assert(value >= 0.0, "value should not be negative")
		attack_rate = value

@abstract
func execute(origin: Node3D, directions: Array[Vector3], audio_player: AudioStreamPlayer3D) -> void


func _play_sound(audio_player: AudioStreamPlayer3D) -> void:
	if sounds.is_empty():
		return
	audio_player.stream = sounds.pick_random()
	audio_player.play()


func _spawn_impact_marker(origin: Node3D, pos: Vector3) -> void:
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
