class_name AmmoCountBehaviour extends AmmoBehaviour

@export var current_ammo: int:
	set(value):
		current_ammo = maxi(0, value)
		emit_changed()
@export var max_ammo: int:
	set(value):
		max_ammo = maxi(0, value)
		emit_changed()
@export var spare_ammo: int:
	set(value):
		spare_ammo = maxi(0, value)
		emit_changed()


func consume(qtd: int = 1) -> int:
	var consumed := mini(current_ammo, maxi(0, qtd))
	current_ammo = clampi(current_ammo - consumed, 0, max_ammo)
	return consumed


func reload() -> bool:
	if not has_reserve() or is_full():
		return false
	var desired := max_ammo - current_ammo
	var available := mini(spare_ammo, desired)
	current_ammo += available
	spare_ammo -= available
	return true


func has_reserve() -> bool:
	return spare_ammo > 0


func is_empty() -> bool:
	return current_ammo == 0


func is_full() -> bool:
	return current_ammo >= max_ammo
