@icon("res://addons/at-icons/node/bullseye.svg")
class_name ProjectileBehaviour extends AttackBehaviour

@export var muzzle_velocity: float
@export var projectile_model: PackedScene


func execute(origin: Node3D, directions: Array[Vector3], audio_player: AudioStreamPlayer3D) -> void:
	var scene_tree := origin.get_tree()

	for direction in directions:
		var projectile := projectile_model.instantiate() as Projectile3D
		scene_tree.current_scene.add_child(projectile)
		projectile.global_position = origin.global_position
		projectile.look_at(projectile.global_position + direction, Vector3.UP)
		projectile.setup(direction * muzzle_velocity, damage)

	_play_sound(audio_player)
