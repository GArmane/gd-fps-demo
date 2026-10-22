class_name WeaponInventoryComponent extends Node

@export var _inventory: WeaponInventory


func get_weapon(key: String) -> WeaponSlot:
	return _inventory.slots.get(key)


func load(resource: WeaponInventory) -> void:
	_inventory = WeaponInventory.new()
	_inventory.copy_from_resource(resource)
