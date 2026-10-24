extends Area3D

signal item_iteracted_with(item)


func _on_body_entered(body: Area3D) -> void:
	item_iteracted_with.emit(body)


## TODO: its working only for pickups, but should work on any Interactable.
func _on_area_entered(area: WeaponPickup) -> void:
	if not is_instance_of(area, WeaponPickup):
		return
	item_iteracted_with.emit(area.get_pickup_item())
	area.queue_free()
