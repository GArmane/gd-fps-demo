@tool
class_name WeaponPickup extends Area3D

@export var _weapon: WeaponResource


func _ready() -> void:
	if not _weapon:
		return
	var model := _weapon.model.instantiate()
	%ItemDisplay.display_object = model
	%ItemDisplay.add_child(model)
	model.global_position = %ItemDisplay.global_position


func get_pickup_item() -> WeaponResource:
	return _weapon
