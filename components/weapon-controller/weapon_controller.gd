@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

signal weapon_switched(previous: Weapon, new: Weapon)

@export var audio_player: AudioStreamPlayer3D
@export var current_weapon: Weapon
@export var weapon_origin: Node3D
@export var center_aim: Node3D

var _weap_model: Node3D
var _weap_muzzl: Node3D


#region Public methods
func trigger_pull():
	%StateChart.send_event("ToTriggerPulled")


func trigger_release():
	%StateChart.send_event("ToTriggerReleased")


func reload_triggered():
	%StateChart.send_event("ToReloading")


func switch_weapon(data: WeaponUnlock):
	if data.weapon == current_weapon or not data.unlocked:
		return
	%StateChart.send_event("ToSwitching")

	var previous_weapon := current_weapon
	var new_weapon := data.weapon
	if _weap_model:
		##TODO: Fake weapon switching delay. Create an effect.
		_weap_model.queue_free()
		await get_tree().create_timer(2).timeout

	_weap_model = new_weapon.model.instantiate()
	weapon_origin.add_child(_weap_model)
	_weap_model.look_at(center_aim.global_position, Vector3.UP)
	_weap_muzzl = _weap_model.get_node(new_weapon.attack_behaviour.muzzle_node_path)

	current_weapon = new_weapon
	weapon_switched.emit(previous_weapon, current_weapon)
	%StateChart.send_event("ToOperational")


#endregion

#region Engine callbacks
#endregion


#region State chart
#region Weapon branch
func _on_reloading_state_entered() -> void:
	if current_weapon.ammo_behaviour.has_reserve() and not current_weapon.ammo_behaviour.is_full():
		await get_tree().create_timer(current_weapon.ammo_behaviour.reload_time).timeout
		current_weapon.ammo_behaviour.reload()
		if $StateChart/Weapon/Operational/Chamber/Empty.active:
			%StateChart.send_event("ToActionCycling")
	%StateChart.send_event("ToOperational")


#endregion
#region Weapon branch
#region Trigger states
func _on_trigger_pulled_state_entered() -> void:
	%StateChart.send_event("ToChamberFiring")


#endregion
#region Action states
func _on_action_cycling_state_entered() -> void:
	if current_weapon.action_behaviour.cycle_time:
		await get_tree().create_timer(1 / current_weapon.action_behaviour.cycle_time).timeout
	if current_weapon.ammo_behaviour.consume():
		%StateChart.send_event("ToChamberChambered")
	%StateChart.send_event("ToActionReady")
	if current_weapon.action_behaviour.type == ActionBehaviour.ActionType.FULL_AUTO:
		if $StateChart/Weapon/Operational/Trigger/Pulled.active:
			%StateChart.send_event("ToChamberFiring")


#endregion
#region Chamber states
func _on_chamber_firing_state_entered() -> void:
	var recoil := current_weapon.recoil_behaviour.get_recoil(_weap_model)
	var spread := current_weapon.spread_behaviour.get_spread_pattern(recoil)

	current_weapon.attack_behaviour.execute(_weap_muzzl, spread, audio_player)
	%StateChart.send_event("ToChamberEmpty")
	%StateChart.send_event("ToActionCycling")

#endregion
#endregion
#endregion
