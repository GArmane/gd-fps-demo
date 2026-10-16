class_name SinglePatternBehaviour extends SpreadBehaviour


func get_spread_pattern(forward: Vector3) -> Array[Vector3]:
	var spread_x := randf_range(-base_spread_x, base_spread_x)
	var spread_y := randf_range(-base_spread_y, base_spread_y)
	var spread = Vector3(spread_x, spread_y, 0)
	return [forward + spread]
