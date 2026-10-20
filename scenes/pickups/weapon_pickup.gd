@tool
class_name WeaponPickup extends Pickup

@export var _weapon: Weapon:
	set(value):
		_weapon = value
		update_display()

var _display_model: Node3D


func update_display() -> void:
	if _display_model:
		_display_model.queue_free()
	if not _weapon:
		return

	_display_model = _weapon.model.instantiate()
	add_child(_display_model)
	%ItemDisplay.display_object = _display_model


func get_pickup() -> Weapon:
	return _weapon


func remove() -> void:
	queue_free()
