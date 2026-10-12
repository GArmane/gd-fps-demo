extends Control

const AMMO_COUNT_TEXT := "AMMO: {0} / {1}"


func attach_player(player: Player3D) -> void:
	var controller := player.weapon_controller
	_update_text(controller.current_ammo, controller.max_ammo)
	controller.weapon_ready.connect(
		func(): _update_text(controller.current_ammo, controller.max_ammo)
	)
	controller.weapon_fired.connect(
		func(): _update_text(controller.current_ammo, controller.max_ammo)
	)
	controller.weapon_empty.connect(
		func(): _update_text(controller.current_ammo, controller.max_ammo)
	)


func _update_text(cur_ammo: int, max_ammo: int) -> void:
	%AmmoCount.text = AMMO_COUNT_TEXT.format([cur_ammo, max_ammo])
