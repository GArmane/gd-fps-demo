class_name AmmoState extends Resource

@export var current_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		current_ammo = mini(max_cur_ammo, value)
		emit_changed()

@export var max_cur_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		max_cur_ammo = value
		emit_changed()

@export var reserve_ammo: int:
	set(value):
		assert(value >= 0, "current ammo should be positive or zero")
		reserve_ammo = value
		emit_changed()


func _init(n_cur: int, n_max: int, n_reserve: int) -> void:
	reserve_ammo = n_reserve
	max_cur_ammo = n_max
	current_ammo = n_cur
