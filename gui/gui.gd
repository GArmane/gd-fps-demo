class_name GUI extends Control

@export var _debug_action: GUIDEAction
@export var _game_mode: GUIDEMappingContext


func attach_player(player: Player) -> GUI:
	%DebugHUD.attach_actor(player)
	return self


func _ready() -> void:
	# Setup canvas layers
	%DebugLayer.visible = (%DebugHUD.state != DebugHUD.State.HIDDEN)
	# GUIDE actions signals
	_debug_action.triggered.connect(_on_debug_action_triggered)
	_game_mode.enabled.connect(_on_game_mode_enabled)
	_game_mode.disabled.connect(_on_game_mode_enabled)


func _on_debug_action_triggered() -> void:
	var state = %DebugHUD.toggle()
	%DebugLayer.visible = (state != DebugHUD.State.HIDDEN)


func _on_game_mode_enabled():
	%ReticleLayer.visible = true


func _on_game_mode_disabled():
	%ReticleLayer.visible = false
