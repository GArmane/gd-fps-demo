class_name RecoilBehaviour extends Resource

@export_range(0, 100, 1.0) var accuracy: float


func get_recoil(muzzle: Node3D) -> Vector3:
	var spread := (100.0 - accuracy) / 1000
	var acc_x := randf_range(-spread, spread)
	var acc_y := randf_range(-spread, spread)
	var basis_z := -muzzle.global_transform.basis.z
	return basis_z + Vector3(acc_x, acc_y, 0)
