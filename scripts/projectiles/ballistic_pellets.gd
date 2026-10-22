class_name BallisticPellets extends BallisticProjectile

@export var base_spread_x: float
@export var base_spread_y: float
@export_range(1, 24) var pellet_count: int


func get_effective_damage() -> int:
	@warning_ignore("integer_division")
	return base_damage / pellet_count
