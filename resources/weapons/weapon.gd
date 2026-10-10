@icon("res://addons/at-icons/node3d/gun.svg")
class_name Weapon extends Resource

@export var name: String
@export var damage: float
@export var max_ammo: int
@export var weapon_model: PackedScene
@export var weapon_position := Vector3.ZERO
@export var fire_sounds: Array[AudioStream]
