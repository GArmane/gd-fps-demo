class_name WeaponInventoryComponent extends Node

@export var _inventory: WeaponInventory


func add_or_refill(weapon: WeaponResource) -> WeaponSlot:
	var slot := get_by_resource(weapon)
	if not slot:
		slot = WeaponSlot.from_weapon(weapon)
		_inventory.slots.append(slot)
	else:
		weapon.ammo_behaviour.refill(slot.ammo_state)

	return slot


func get_by_resource(weapon: WeaponResource) -> WeaponSlot:
	var idx := _inventory.slots.find_custom(func(slot: WeaponSlot): return slot.weapon == weapon)
	return _inventory.slots.get(idx) if idx != -1 else null


func load(resource: WeaponInventory) -> void:
	_inventory = WeaponInventory.new()
	_inventory.copy_from_resource(resource)
