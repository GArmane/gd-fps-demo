class_name AmmoState extends Resource

const INITIAL_MAGS := 3

@export var current_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		current_ammo = mini(max_cur_ammo, value)
		emit_changed()

@export var max_cur_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		max_cur_ammo = value
		emit_changed()

@export var reserve_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		reserve_ammo = value
		emit_changed()


func _init(n_cur: int = 0, n_max: int = 0, n_reserve: int = 0) -> void:
	reserve_ammo = n_reserve
	max_cur_ammo = n_max
	current_ammo = n_cur


static func from_weapon_resource(weapon: WeaponResource) -> AmmoState:
	var ammo_behaviour := weapon.ammo_behaviour
	if is_instance_of(ammo_behaviour, AmmoCounterBehaviour):
		return AmmoState.new(
			ammo_behaviour.max_ammo_per_mag,
			ammo_behaviour.max_ammo_per_mag,
			ammo_behaviour.max_ammo_per_mag * INITIAL_MAGS
		)
	assert(false, "ammo initialization not implemented")
	return null
