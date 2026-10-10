class_name MouseCapture extends Component

@export var _mouse_action: GUIDEAction

@export_category("Mouse Capture Settings")
@export var mode := Input.MOUSE_MODE_CAPTURED
@export_range(0.0, 50.0) var sensitivity := 12.0

var raw_direction: Vector2:
	get():
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return Vector2.ZERO
		return _mouse_action.value_axis_2d
var direction: Vector2:
	get():
		return raw_direction * sensitivity


#region Engine callbacks
func _ready() -> void:
	Input.mouse_mode = mode

#endregion
