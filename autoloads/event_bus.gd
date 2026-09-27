extends Node

signal pause
signal unpause
signal quit


func _ready() -> void:
	for p_signal in [quit, pause, unpause]:
		p_signal.connect(func(): _log_event(p_signal.get_name()))


func _log_event(event_name: String) -> void:
	print("(%s): %s emitted" % [name, event_name])
