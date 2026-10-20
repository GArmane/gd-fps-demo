class_name ItemDisplayComponent extends Node3D

@export_category("Display")
@export var display_object: Node3D

@export_category("Bobbing animation")
@export var rotation_speed: float
@export var float_speed: float
@export var float_height: float

@onready var _start_y := position.y
@onready var _time := 0.0


func _physics_process(delta: float) -> void:
	if not display_object:
		return
	_time = fmod(_time + delta, TAU)
	display_object.position.y = _start_y + sin(_time * float_speed) * float_height
	display_object.rotate_y(deg_to_rad(rotation_speed) * delta)
