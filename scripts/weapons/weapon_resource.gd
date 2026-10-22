@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponResource extends Resource

@export var model: PackedScene
@export var name: String
@export_multiline() var description: String
@export var muzzle_node_path: String
@export var equipping_time: float

@export_category("Behaviours")
@export var action_behaviour: ActionBehaviour
@export var attack_behaviour: AttackBehaviour
@export var ammo_behaviour: AmmoBehaviour
@export var recoil_behaviour: RecoilBehaviour
