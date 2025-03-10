extends Control

func _on_button_button_up() -> void:
	get_parent().start_intro()
	queue_free()
