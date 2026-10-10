@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

@export var current_weapon: Weapon
@export var weapon_model_parent: Node3D

var current_weapon_model: Node3D


func _ready() -> void:
	if current_weapon:
		_spawn_weapon_model()


func _spawn_weapon_model() -> void:
	if current_weapon_model:
		current_weapon_model.queue_free()

	current_weapon_model = current_weapon.weapon_model.instantiate()
	weapon_model_parent.add_child(current_weapon_model)
	current_weapon_model.position = current_weapon.weapon_position
