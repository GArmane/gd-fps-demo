@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

signal weapon_empty
signal weapon_fired
signal weapon_ready
signal weapon_reload_started
signal weapon_reload_finished

@export var audio_player: AudioStreamPlayer3D
@export var current_weapon: Weapon
@export var fire_origin: Marker3D
@export var hitscan_origin: Marker3D
@export var weapon_pos: Node3D

var current_ammo: int:
	get():
		return _current_ammo
var max_ammo: int:
	get():
		return current_weapon.max_ammo

var _weap_model: Node3D
var _current_ammo: int = 0


func fire() -> void:
	%StateChart.send_event("ToFire")


func reload() -> void:
	%StateChart.send_event("ToReload")


func _spawn_weapon_model():
	if _weap_model:
		_weap_model.queue_free()

	_weap_model = current_weapon.model.instantiate()
	weapon_pos.add_child(_weap_model)


#region Engine callbacks
func _ready() -> void:
	if not current_weapon:
		return
	_spawn_weapon_model()
	_current_ammo = current_weapon.max_ammo


#endregion


#region State machine
func _on_ready_state_entered() -> void:
	weapon_ready.emit()


func _on_fire_state_entered() -> void:
	current_weapon.attack_behaviour.execute(fire_origin, audio_player)
	weapon_fired.emit()


func _on_fire_state_physics_processing(_delta: float) -> void:
	_current_ammo -= 1

	if _current_ammo <= 0:
		%StateChart.send_event("ToEmpty")
	else:
		%StateChart.send_event("ToReady")


func _on_empty_state_entered() -> void:
	weapon_empty.emit()


func _on_reload_state_entered() -> void:
	weapon_reload_started.emit()
	get_tree().create_timer(current_weapon.reload_time).timeout.connect(
		func():
			_current_ammo = max_ammo
			%StateChart.send_event("ToReady")
	)


func _on_reload_state_exited() -> void:
	weapon_reload_finished.emit()

#endregion
