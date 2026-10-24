@icon("res://addons/at-icons/node/archive_arrow_down.svg")
class_name WeaponSlot extends Resource

@export var weapon: WeaponResource
@export var ammo_state: AmmoState


static func from_weapon(n_weapon: WeaponResource) -> WeaponSlot:
	return WeaponSlot.new(n_weapon, AmmoState.from_weapon_resource(n_weapon))


func _init(n_weapon: WeaponResource = null, n_ammo_state: AmmoState = null) -> void:
	weapon = n_weapon
	ammo_state = n_ammo_state
