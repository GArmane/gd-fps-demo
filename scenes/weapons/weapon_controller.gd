class_name WeaponController extends Node

signal weapon_equiped
signal weapon_unequiped

@export_category("Resource")
@export var _resource: WeaponResource

var ammo_state: AmmoState:
	get():
		return _ammo_state

var _ammo_state: AmmoState
var _action_behaviour: ActionBehaviour
var _attack_behaviour: AttackBehaviour
var _ammo_behaviour: AmmoBehaviour
var _recoil_behaviour: RecoilBehaviour

var _weap_model: Node3D
var _weap_muzzl: Node3D


#region Public methods
func pull_trigger():
	%StateChart.send_event("ToTriggerPulled")


func release_trigger():
	%StateChart.send_event("ToTriggerReleased")


func reload_weapon():
	%StateChart.send_event("ToWeaponReloading")


func switch_to_weapon(
	resource: WeaponResource, state: AmmoState, weapon_origin: Node3D, hipfire_aim_point: Node3D
):
	%StateChart.send_event("ToWeaponUnarmed")

	if _weap_model:
		_weap_model.queue_free()
	##TODO: Real weapon switching effect.
	await get_tree().create_timer(resource.equipping_time).timeout

	_resource = resource
	_action_behaviour = _resource.action_behaviour
	_attack_behaviour = _resource.attack_behaviour
	_ammo_behaviour = _resource.ammo_behaviour
	_recoil_behaviour = _resource.recoil_behaviour
	_ammo_state = state
	_weap_model = _resource.model.instantiate()
	_weap_muzzl = _weap_model.get_node(_resource.muzzle_node_path)
	weapon_origin.add_child(_weap_model)
	_weap_model.look_at(hipfire_aim_point.global_position, Vector3.UP)

	%StateChart.send_event("ToWeaponOperational")


#endregion


#region State chart
func _on_weapon_operational_state_entered() -> void:
	weapon_equiped.emit()


func _on_operational_state_exited() -> void:
	weapon_unequiped.emit()


func _on_trigger_pulled_state_entered() -> void:
	%StateChart.send_event("ToChamberFiring")


func _on_action_cycling_state_entered() -> void:
	await get_tree().create_timer(1 / _action_behaviour.cycle_time).timeout
	# Load the chamber.
	if _ammo_behaviour.can_consume(_ammo_state):
		_ammo_behaviour.consume(_ammo_state)
		%StateChart.send_event("ToChamberChambered")
	# Ready the action, restart the cycle.
	%StateChart.send_event("ToActionReady")
	if _action_behaviour.fire_mode == ActionBehaviour.FireModes.FULL_AUTO:
		if $StateChart/Weapon/Operational/Trigger/Pulled.active:
			%StateChart.send_event("ToChamberFiring")


func _on_chamber_firing_state_entered() -> void:
	var direction := _recoil_behaviour.get_recoil(_weap_muzzl)
	_attack_behaviour.execute(_weap_muzzl, direction)
	%StateChart.send_event("ToChamberEmpty")
	%StateChart.send_event("ToActionCycling")


func _on_weapon_reloading_state_entered() -> void:
	if _ammo_behaviour.can_reload(_ammo_state):
		await get_tree().create_timer(_ammo_behaviour.reload_time).timeout
		_ammo_behaviour.reload(_ammo_state)
		if $StateChart/Weapon/Operational/Chamber/Empty.active:
			%StateChart.send_event("ToActionCycling")
	%StateChart.send_event("ToWeaponOperational")

#endregion
