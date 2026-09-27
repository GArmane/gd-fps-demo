extends Control

@export_file("*.tscn") var start_level


func _on_exit_button_pressed() -> void:
	GameController.quit()


func _on_start_button_pressed() -> void:
	GameController.change_level(start_level)
