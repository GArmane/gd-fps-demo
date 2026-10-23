extends Control

const AMMO_COUNT_TEXT := "AMMO: {0} / {1}"


func _ready() -> void:
	_clear_text()


func attach_actor(player: Player3D):
	var weapon_controller: WeaponController = player.weapon_controller

	weapon_controller.weapon_equiped.connect(
		func():
			var ammo_state = weapon_controller.ammo_state
			var upd_func := _update_text.bind(ammo_state)
			ammo_state.changed.connect(upd_func)
			upd_func.call_deferred()
	)
	weapon_controller.weapon_unequiped.connect(
		func():
			weapon_controller.ammo_state.changed.disconnect(_update_text)
			_clear_text()
	)


func _clear_text():
	%AmmoCount.text = AMMO_COUNT_TEXT.format(["--", "--"])


func _update_text(ammo: AmmoState):
	%AmmoCount.text = AMMO_COUNT_TEXT.format([ammo.current_ammo, ammo.reserve_ammo])
