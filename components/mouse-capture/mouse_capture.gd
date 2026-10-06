class_name MouseCapture extends Component

signal mouse_movement(vec: Vector2)

@export var _mouse_action: GUIDEAction

@export_category("Mouse Capture Settings")
@export var mode := Input.MOUSE_MODE_CAPTURED
@export_range(0.0, 50.0) var sensitivity := 12.0

var relative_position: Vector2:
	get():
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return Vector2.ZERO
		return _mouse_action.value_axis_2d * sensitivity


#region Engine callbacks
func _ready() -> void:
	Input.mouse_mode = mode
	_mouse_action.triggered.connect(_on_mouse_action_triggered)


#endregion


#region Signal handlers
func _on_mouse_action_triggered() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	mouse_movement.emit(_mouse_action.value_axis_2d * sensitivity)
#endregion
