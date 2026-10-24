class_name AmmoCounterBehaviour extends AmmoBehaviour

@export var initial_mags: int:
	set(value):
		assert(value >= 0, "initial mags should be positive or zero")
		initial_mags = value
@export var max_ammo_per_mag: int:
	set(value):
		assert(value >= 0, "max ammo per magazine should be positive or zero")
		max_ammo_per_mag = value
@export var units_consumed_per_shot: int:
	set(value):
		assert(value >= 0, "units consumed per shot should be positive or zero")
		units_consumed_per_shot = value
@export var reload_time: float:
	set(value):
		assert(value >= 0, "reload time should be positive or zero")
		reload_time = value


func can_consume(state: AmmoState) -> bool:
	return state.current_ammo >= units_consumed_per_shot


func consume(state: AmmoState) -> AmmoState:
	var consumed := mini(state.current_ammo, units_consumed_per_shot)
	state.current_ammo = clampi(state.current_ammo - consumed, 0, max_ammo_per_mag)
	return state


func can_reload(state: AmmoState) -> bool:
	return state.reserve_ammo > 1 and state.current_ammo < max_ammo_per_mag


func reload(state: AmmoState) -> AmmoState:
	if not can_reload(state):
		return state

	var desired := max_ammo_per_mag - state.current_ammo
	var available := mini(state.reserve_ammo, desired)
	state.current_ammo += available
	state.reserve_ammo -= available
	return state


func refill(state: AmmoState) -> AmmoState:
	state.reserve_ammo += max_ammo_per_mag
	return state
