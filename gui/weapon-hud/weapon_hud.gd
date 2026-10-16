extends Control

const AMMO_COUNT_TEXT := "AMMO: {0} / {1}"


func attach_actor(player: Player3D):
	var ammo_counter := player.weapon_controller.current_weapon.ammo_behaviour
	if not ammo_counter:
		%AmmoCount.text = AMMO_COUNT_TEXT.format(["--", "--"])
		return
	var update_func := func():
		%AmmoCount.text = AMMO_COUNT_TEXT.format(
			[ammo_counter.current_ammo, ammo_counter.spare_ammo]
		)
	ammo_counter.changed.connect(update_func)
	update_func.call_deferred()
