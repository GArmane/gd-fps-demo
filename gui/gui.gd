class_name GUI extends Control

@export var _debug_action: GUIDEAction


func attach_player(player: Player) -> GUI:
	%DebugHUD.attach_actor(player)
	return self


func _ready() -> void:
	# Setup canvas layers
	%DebugLayer.visible = (%DebugHUD.state != DebugHUD.State.HIDDEN)
	# GUIDE actions signals
	_debug_action.triggered.connect(_on_debug_action_triggered)


func _on_debug_action_triggered() -> void:
	var state = %DebugHUD.toggle()
	%DebugLayer.visible = (state != DebugHUD.State.HIDDEN)
