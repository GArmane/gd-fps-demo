extends Node

var _gui_scene = preload("res://gui/gui.tscn")
var _current_gui: GUI

#region GUIDE input modes
var _debug_mode: GUIDEMappingContext = preload("res://input/debug-mode/debug_mode.tres")
#endregion

#region Engine callbacks
#endregion


#region Game public API
func start_game(level_path: String) -> void:
	# Load level
	_change_level(level_path)


func quit():
	# Emit quit event so any subscribed node can execute some behaviour before
	# defacto program termination.
	EventBus.quit.emit()

	# Propagate process exit request so nodes can react to the event,
	# then call quit/0 to actually terminate the process.
	var scene_tree = get_tree()
	scene_tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	scene_tree.quit()


func _change_level(level_path: String) -> void:
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


## Get current active GUI, or create one if no GUI has been created.
func _get_current_gui() -> GUI:
	if _current_gui == null:
		_current_gui = _gui_scene.instantiate()
	return _current_gui


#endregion


#region Input modes handling
func switch_to_game_mode():
	_switch_input_game_modes([_debug_mode], [])
	get_tree().paused = false


func _switch_input_game_modes(
	enable_modes: Array[GUIDEMappingContext],
	disable_modes: Array[GUIDEMappingContext],
):
	disable_modes.map(func(mode): GUIDE.disable_mapping_context(mode))
	enable_modes.map(func(mode): GUIDE.enable_mapping_context(mode))
#endregion

#region Signal handlers
#endregion
