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
	var new_mag: int = magazines.pop_front()
	var old_mag := current_mag
	current_mag = new_mag
	magazines.push_back(old_mag)
	return true
