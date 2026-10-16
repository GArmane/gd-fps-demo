@icon("res://addons/at-icons/node3d/gun.svg")
class_name Weapon extends Resource

@export var name: String
@export_multiline() var description: String
@export var model: PackedScene

@export var ammo_behaviour: AmmoBehaviour
@export var attack_behaviour: AttackBehaviour
@export var loading_behaviour: LoadingBehaviour
@export var recoil_behaviour: RecoilBehaviour
