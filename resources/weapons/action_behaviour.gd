class_name ActionBehaviour extends Resource

enum ActionType { SEMI_AUTO, FULL_AUTO }

@export var type: ActionType
@export var cycle_time: float:
	set(value):
		assert(value >= 0.0, "value should not be negative")
		cycle_time = value
