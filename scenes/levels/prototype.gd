extends Node3D

@export var _player: Player3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await _player.active
	GameController.current_gui.attach_player(_player)
	GameController.switch_to_game_mode()
