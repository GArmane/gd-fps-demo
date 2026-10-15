@icon("res://addons/at-icons/node/ammunition.svg")
class_name MagazineBehaviour extends AmmoBehaviour

@export var current_mag: int:
	set(value):
		current_mag = max(0, value)
@export var magazines: Array[int]


func consume() -> bool:
	if is_empty():
		return false
	current_mag -= 1
	return true


func is_empty() -> bool:
	return current_mag == 0


func reload() -> bool:
	if magazines.is_empty():
		return false

	var new_mag_idx := magazines.find_custom(func(x): return x != 0)
	if new_mag_idx == -1:
		return false

	var old_mag := current_mag
	current_mag = magazines.pop_at(new_mag_idx)
	magazines.push_back(old_mag)
	return true
