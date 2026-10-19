extends Control

const AMMO_COUNT_TEXT := "AMMO: {0} / {1}"


func attach_actor(player: Player3D):
	var weapon_controller := player.weapon_controller
	weapon_controller.weapon_switched.connect(_on_weapon_controller_weapon_switched)


func _update_text(ammo: AmmoBehaviour):
	%AmmoCount.text = AMMO_COUNT_TEXT.format([ammo.current_ammo, ammo.spare_ammo])


func _on_weapon_controller_weapon_switched(previous: Weapon, new: Weapon) -> void:
	# Disconnect previous weapon.
	if (
		previous
		and previous.ammo_behaviour
		and previous.ammo_behaviour.changed.is_connected(_update_text)
	):
		previous.ammo_behaviour.changed.disconnect(_update_text)
	# Check for ammo behaviour on new weapon. Only connected if there is a
	# weapon behaviour.
	if not new.ammo_behaviour:
		%AmmoCount.text = AMMO_COUNT_TEXT.format(["--", "--"])
		return
	var upd_func := _update_text.bind(new.ammo_behaviour)
	upd_func.call_deferred()
	new.ammo_behaviour.changed.connect(upd_func)
