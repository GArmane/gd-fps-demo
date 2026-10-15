@icon("res://addons/at-icons/node/bullseye.svg")
class_name ProjectileBehaviour extends AttackBehaviour

@export var muzzle_velocity: float
@export var projectile_model: PackedScene


func execute(origin: Node3D, audio_player: AudioStreamPlayer3D) -> void:
	var projectile := projectile_model.instantiate() as Projectile3D
	var scene_tree := origin.get_tree()

	scene_tree.current_scene.add_child(projectile)
	projectile.global_position = origin.global_position

	var frwd := -origin.global_transform.basis.z
	var velocity: Vector3 = frwd * muzzle_velocity

	projectile.look_at(projectile.global_position + frwd, Vector3.UP)
	projectile.setup(velocity, damage)

	_play_sound(audio_player)
