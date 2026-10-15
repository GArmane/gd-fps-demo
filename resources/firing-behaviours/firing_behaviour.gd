@icon("res://addons/at-icons/node/laser_gun.svg")
@abstract
class_name LoadingBehaviour extends Resource

@abstract func load_() -> bool
@abstract func is_loaded() -> bool
@abstract func execute() -> bool
@abstract func unload() -> bool
