extends Control

const AMMO_COUNT_TEXT := "AMMO: {0} / {1}"


func attach_player(player: Player3D) -> void:
	var controller := player.weapon_controller
	var update_function := _update_text.bind(controller.current_weapon)
	controller.weapon_ready.connect(update_function)
	controller.weapon_attacking.connect(update_function)
	update_function.call()


func _update_text(weapon: Weapon) -> void:
	if not weapon.ammo_behaviour:
		%AmmoCount.text = AMMO_COUNT_TEXT.format(["--", "--"])
		return
	var mag := weapon.ammo_behaviour as MagazineBehaviour
	%AmmoCount.text = AMMO_COUNT_TEXT.format([mag.current_ammo, mag.reserve_ammo])
