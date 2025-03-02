extends Node2D

var elapsed_time = 0

func _process(delta: float) -> void:
	elapsed_time += delta
	
	if elapsed_time > 5:
		$Stuff.set_cell(Vector2i(8, 2), 2, Vector2i(0, 0))
	
	if elapsed_time > 6 or Input.is_action_just_pressed("skip"):
		get_parent().start_game()
		
		queue_free()
