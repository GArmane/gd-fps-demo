class_name AmmoState extends Resource

@export var current_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		current_ammo = value
		emit_changed()

@export var reserve_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		reserve_ammo = value
		emit_changed()


static func from_weapon_resource(weapon: WeaponResource) -> AmmoState:
	var ammo_behaviour := weapon.ammo_behaviour
	if is_instance_of(ammo_behaviour, AmmoCounterBehaviour):
		return AmmoState.new(
			ammo_behaviour.max_ammo_per_mag,
			ammo_behaviour.max_ammo_per_mag * ammo_behaviour.initial_mags
		)
	assert(false, "ammo initialization not implemented")
	return null


func _init(n_cur: int = 0, n_reserve: int = 0) -> void:
	reserve_ammo = n_reserve
	current_ammo = n_cur
