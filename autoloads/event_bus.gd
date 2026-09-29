extends Node

signal switch_debug_mode

signal quit
signal pause
signal unpause


func _ready() -> void:
	for p_signal in [quit, pause, switch_debug_mode, unpause]:
		p_signal.connect(func(): _log_event(p_signal.get_name()))


func _log_event(event_name: String) -> void:
	print("(%s): %s emitted" % [name, event_name])
