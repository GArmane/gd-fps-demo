class_name DebugHUD extends Control

enum State { HIDDEN, SHOW_GUIDE, SHOW_STATE_CHART }

@export var inital_state := State.HIDDEN
@onready var state: State:
	set(value):
		state = value
		match state:
			State.HIDDEN:
				_show_elements([])
			State.SHOW_GUIDE:
				_show_elements([%GuideDebugger])
			State.SHOW_STATE_CHART:
				_show_elements([%StateChartDebugger])


func attach_actor(node: Node) -> void:
	%StateChartDebugger.debug_node(node)


func toggle() -> State:
	state = ((state + 1) % State.size()) as State
	return state


func _show_elements(elements: Array[Control] = []):
	visible = !elements.is_empty()
	get_children().map(func(child): child.visible = child in elements)


func _ready() -> void:
	state = inital_state
