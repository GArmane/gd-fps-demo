extends Node3D

@export var _player: Player3D

@export var _debug_mode: GUIDEMappingContext
@export var _move_mode: GUIDEMappingContext
@export var _pause_mode: GUIDEMappingContext
@export var _weapon_mode: GUIDEMappingContext
@export var _inventory_mode: GUIDEMappingContext


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await _player.active
	GameController.current_gui.attach_player(_player)
	(
		GameController
		. switch_input_game_modes(
			[_debug_mode, _move_mode, _pause_mode, _inventory_mode, _weapon_mode],
			[],
		)
	)
