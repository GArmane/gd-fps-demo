@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

@export var audio_player: AudioStreamPlayer3D
@export var current_weapon: Weapon
@export var weapon_origin: Node3D
@export var center_aim: Node3D

var _weap_model: Node3D
var _weap_muzzl: Node3D


#region Public methods
func attack():
	%StateChart.send_event("ToFiring")


func reload():
	%StateChart.send_event("ToReloading")


#endregion


#region Engine callbacks
func _ready() -> void:
	if not current_weapon:
		return

	_weap_model = current_weapon.model.instantiate()
	weapon_origin.add_child(_weap_model)
	_weap_model.look_at(center_aim.global_position, Vector3.UP)
	_weap_muzzl = _weap_model.get_node(current_weapon.attack_behaviour.muzzle_node_path)


#endregion


#region State chart
func _on_ready_state_entered() -> void:
	current_weapon.ammo_behaviour.emit_changed()


func _on_firing_state_processing(_delta: float) -> void:
	var shots_fired: Array[Vector3] = []
	for shot in current_weapon.ammo_behaviour.consume():
		var recoil := current_weapon.recoil_behaviour.get_recoil(_weap_model)
		var spread := current_weapon.spread_behaviour.get_spread_pattern(recoil)
		shots_fired.append_array(spread)

	current_weapon.attack_behaviour.execute(_weap_muzzl, shots_fired, audio_player)
	if current_weapon.ammo_behaviour.is_empty():
		%StateChart.send_event("ToEmpty")
	else:
		%StateChart.send_event("ToCooldown")


func _on_cooldown_state_entered() -> void:
	(
		get_tree()
		. create_timer(1 / current_weapon.attack_behaviour.attack_rate, false, true)
		. timeout
		. connect(%StateChart.send_event.bind("ToReady"))
	)


func _on_reloading_state_processing(_delta: float) -> void:
	current_weapon.ammo_behaviour.reload()
	if current_weapon.ammo_behaviour.is_empty():
		%StateChart.send_event("ToEmpty")
	else:
		%StateChart.send_event("ToReady")


func _on_empty_state_entered() -> void:
	current_weapon.ammo_behaviour.emit_changed()

#endregion
