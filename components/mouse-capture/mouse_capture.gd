class_name MouseCapture extends Component

@export_category("Mouse Capture Settings")
@export var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity: float = 0.1

var _capture_mouse: bool = false
var _mouse_input: Vector2 = Vector2.ZERO

var input: Vector2:
	get():
		return _mouse_input


#region Engine callbacks
func _unhandled_input(event: InputEvent) -> void:
	_capture_mouse = (
		event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	)
	if _capture_mouse:
		_mouse_input.x = -event.screen_relative.x * mouse_sensitivity
		_mouse_input.y = -event.screen_relative.y * mouse_sensitivity


func _ready() -> void:
	Input.mouse_mode = current_mouse_mode


func _process(_delta: float) -> void:
	_mouse_input = Vector2.ZERO
#endregion
