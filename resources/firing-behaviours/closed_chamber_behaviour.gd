@icon("res://addons/at-icons/node/laser_gun.svg")
class_name ClosedChamberBehaviour extends LoadingBehaviour

## This class only exists to keep a sort of basis for future different
## chamber behaviours. And it controls when a chamber is loaded, so
## its easier to show the difference between a full mag + full chamber
## reload, and a full mag + empty chamber.

@export var loaded: bool


func load_() -> bool:
	loaded = true
	return true


func is_loaded() -> bool:
	return loaded


func execute() -> bool:
	loaded = false
	return true


func unload() -> bool:
	loaded = false
	return true
