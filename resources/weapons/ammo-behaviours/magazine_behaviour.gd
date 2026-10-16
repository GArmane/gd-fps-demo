@icon("res://addons/at-icons/node/ammunition.svg")
class_name MagazineBehaviour extends AmmoBehaviour

@export var current_mag: int:
	set(value):
		current_mag = max(0, value)
@export var spare_magazines: Array[int]


func consume(qtd: int = 1) -> int:
	if is_empty():
		return 0

	var consumed := mini(current_mag, maxi(0, qtd))
	current_mag = maxi(0, current_mag - consumed)
	return current_mag


func reload() -> bool:
	var new_mag_idx := spare_magazines.find_custom(func(x): return x != 0)
	if new_mag_idx == -1:
		return false

	var old_mag := current_mag
	current_mag = spare_magazines.pop_at(new_mag_idx)
	spare_magazines.push_back(old_mag)
	return true


func has_reserve() -> bool:
	push_error("not implemented")
	return false


func is_empty() -> bool:
	return current_mag == 0


func is_full() -> bool:
	return current_mag > 0
