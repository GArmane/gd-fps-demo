@icon("res://addons/at-icons/node/bullseye.svg")
class_name HitscanBehaviour extends AttackBehaviour

@export var max_range: float


func execute(origin: Node3D, directions: Array[Vector3], audio_player: AudioStreamPlayer3D) -> void:
	var space_state = origin.get_world_3d().direct_space_state
	var from := origin.global_position

	for direction in directions:
		var to: Vector3 = from + direction * max_range

		var query := PhysicsRayQueryParameters3D.create(from, to)
		var res := space_state.intersect_ray(query)

		if res:
			_spawn_impact_marker(origin, res.position)
	_play_sound(audio_player)
