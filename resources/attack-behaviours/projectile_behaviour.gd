@icon("res://addons/at-icons/node/bullseye.svg")
class_name ProjectileBehaviour extends AttackBehaviour

@export var muzzle_velocity: float
@export var projectile_model: PackedScene


func execute(origin: Node3D, recoil: Vector3, audio_player: AudioStreamPlayer3D) -> void:
	var projectile := projectile_model.instantiate() as Projectile3D
	var scene_tree := origin.get_tree()
	scene_tree.current_scene.add_child(projectile)

	projectile.global_position = origin.global_position
	projectile.look_at(projectile.global_position + recoil, Vector3.UP)
	projectile.setup(recoil * muzzle_velocity, damage)

	_play_sound(audio_player)
