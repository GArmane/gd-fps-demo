extends RayCast3D

var target: Node


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not is_colliding():
		target = null
		return

	var object := get_collider()
	if target == object:
		return
	target = object
