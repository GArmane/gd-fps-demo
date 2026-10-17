class_name PelletPatternBehaviour extends SinglePatternBehaviour

@export_range(1, 24) var pellet_count: int


func get_spread_pattern(forward: Vector3) -> Array[Vector3]:
	var res: Array[Vector3] = []
	for i in pellet_count:
		res.append_array(super.get_spread_pattern(forward))
	return res
