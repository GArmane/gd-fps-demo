@icon("res://addons/at-icons/node/bullet.svg")
class_name BallisticProjectile extends Resource

const DEFAULT_LIFETIME = 5.0

@export var model: PackedScene
@export var name: String
@export_multiline() var description: String

@export var base_damage: int
@export var base_velocity: float
@export var lifetime: float = DEFAULT_LIFETIME


func get_effective_damage() -> int:
	return base_damage
