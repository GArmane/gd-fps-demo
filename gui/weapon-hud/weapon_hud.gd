extends Control

const AMMO_COUNT_TEXT := "AMMO: {0} / {1}"


func attach_actor(player: Player3D):
	var weapon_controller: WeaponController = player.weapon_controller

	weapon_controller.weapon_ready.connect(
		func():
			var ammo_state = weapon_controller.ammo_state
			var upd_func := func(): _update_text(ammo_state)
			upd_func.call_deferred()
			ammo_state.changed.connect(upd_func)
	)


func _update_text(ammo: AmmoState):
	%AmmoCount.text = AMMO_COUNT_TEXT.format([ammo.current_ammo, ammo.reserve_ammo])


func _on_ammo_state_changed(state: AmmoState):
	_update_text(state)
