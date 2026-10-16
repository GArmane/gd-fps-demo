@abstract
class_name SpreadBehaviour extends Resource

@export_range(0.0, 1.0) var base_spread_x: float
@export_range(0.0, 1.0) var base_spread_y: float

@abstract func get_spread_pattern(forward: Vector3) -> Array[Vector3]
