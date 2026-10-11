@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

signal weapon_empty
signal weapon_fired
signal weapon_ready

@export var audio_player: AudioStreamPlayer3D
@export var current_weapon: Weapon
@export var weapon_pos: Node3D

var _weap_model: Node3D
var _current_ammo: int = 0


func fire() -> void:
	%StateChart.send_event("ToFire")


func _spawn_weapon_model():
	if _weap_model:
		_weap_model.queue_free()

	_weap_model = current_weapon.weapon_model.instantiate()
	weapon_pos.add_child(_weap_model)
	_weap_model.position = current_weapon.weapon_position


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
	weapon_fired.emit()


func _on_fire_state_physics_processing(_delta: float) -> void:
	_current_ammo -= 1
	if audio_player:
		var sound: AudioStream = current_weapon.fire_sounds.pick_random()
		if sound:
			audio_player.stream = sound
			audio_player.play()

	if _current_ammo <= 0:
		%StateChart.send_event("ToEmpty")
	else:
		%StateChart.send_event("ToReady")


func _on_empty_state_entered() -> void:
	weapon_empty.emit()
#endregion
