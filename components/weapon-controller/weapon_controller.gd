@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

@export var audio_player: AudioStreamPlayer3D
@export var current_weapon: Weapon
@export var attack_origin: Marker3D
@export var weapon_origin: Node3D

var _weap_model: Node3D


#region Public methods
func attack() -> void:
	%StateChart.send_event("ToFiring")


func reload() -> void:
	%StateChart.send_event("ToReloading")


#endregion


#region Private methods
func _spawn_weapon_model():
	if _weap_model:
		_weap_model.queue_free()

	_weap_model = current_weapon.model.instantiate()
	weapon_origin.add_child(_weap_model)


#endregion


#region Engine callbacks
func _ready() -> void:
	if not current_weapon:
		return
	_spawn_weapon_model()


#endregion


#region State chart
func _on_ready_state_entered() -> void:
	var mag := current_weapon.ammo_behaviour as MagazineBehaviour
	var chb := current_weapon.loading_behaviour as ClosedChamberBehaviour
	var is_loaded := chb.is_loaded()
	print(
		"DEBUG: AMMO: {0} | CHAMBER: {1} | MAGS: {2}".format(
			[mag.current_mag, is_loaded, str(mag.magazines)]
		)
	)


func _on_firing_state_physics_processing(_delta: float) -> void:
	if not current_weapon.loading_behaviour.execute():
		%StateChart.send_event("ToEmpty")
		return
	current_weapon.attack_behaviour.execute(attack_origin, audio_player)
	%StateChart.send_event("ToLoading")


func _on_loading_state_physics_processing(_delta: float) -> void:
	if current_weapon.ammo_behaviour.is_empty():
		%StateChart.send_event("ToEmpty")
		return
	if not current_weapon.loading_behaviour.is_loaded():
		current_weapon.ammo_behaviour.consume()
		current_weapon.loading_behaviour.load_()
	%StateChart.send_event("ToReady")


func _on_reloading_state_physics_processing(_delta: float) -> void:
	if not current_weapon.ammo_behaviour.reload():
		return
	%StateChart.send_event("ToLoading")


func _on_empty_state_entered() -> void:
	var mag := current_weapon.ammo_behaviour as MagazineBehaviour
	var chb := current_weapon.loading_behaviour as ClosedChamberBehaviour
	var is_loaded := chb.is_loaded()
	print(
		"DEBUG: AMMO: {0} | CHAMBER: {1} | MAGS: {2}".format(
			[mag.current_mag, is_loaded, str(mag.magazines)]
		)
	)
#endregion
