extends Area3D

signal item_iteracted_with(item)


func _on_body_entered(body: Area3D) -> void:
	item_iteracted_with.emit(body)
