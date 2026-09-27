extends Node


#region Engine callbacks
func _ready() -> void:
	EventBus.pause.connect(_on_event_bus_pause)
	EventBus.unpause.connect(_on_event_bus_unpause)
	print("Hello World!")


#endregion


#region Game public API
func change_level(level_path: String) -> void:
	# Pause current scene so it can finish any process leftover.
	var scene_tree = get_tree()
	scene_tree.paused = true
	await scene_tree.process_frame

	## Load new level.
	var res = scene_tree.change_scene_to_file(level_path)
	assert(res == OK, "(%s): Failed to load level with status %s" % [name, res])

	## Unpause scene and resume game.
	scene_tree.paused = false
	await scene_tree.process_frame


func quit():
	# Emit quit event so any subscribed node can execute some behaviour before
	# defacto program termination.
	EventBus.quit.emit()

	# Propagate process exit request so nodes can react to the event,
	# then call quit/0 to actually terminate the process.
	var scene_tree = get_tree()
	scene_tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	scene_tree.quit()


#endregion


#region Input modes handling
func _switch_input_game_modes(
	enable_modes: Array[GUIDEMappingContext],
	disable_modes: Array[GUIDEMappingContext],
):
	disable_modes.map(func(mode): GUIDE.disable_mapping_context(mode))
	enable_modes.map(func(mode): GUIDE.enable_mapping_context(mode))


func _switch_to_game_mode():
	get_tree().paused = false


func _switch_to_pause_mode():
	get_tree().paused = true


#endregion


#region Signal handlers
func _on_event_bus_pause() -> void:
	_switch_to_pause_mode()


func _on_event_bus_unpause() -> void:
	_switch_to_game_mode()
#endregion
