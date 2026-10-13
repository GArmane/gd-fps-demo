@icon("res://addons/at-icons/node3d/gun.svg")
class_name Weapon extends Resource

@export var name: String
@export_multiline() var description: String
@export var model: PackedScene
## TODO move to ammo behaviour
@export var max_ammo: int = 12

@export var attack_behaviour: AttackBehaviour
