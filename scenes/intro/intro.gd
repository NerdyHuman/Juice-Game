extends Node2D

var elapsed_time = 0

func _process(delta: float) -> void:
	elapsed_time += delta

	if elapsed_time > 5:
		$Stuff.set_cell(Vector2i(8, 2), 2, Vector2i(0, 0))

	if elapsed_time > 6 or Input.is_action_just_pressed("skip"):
		print("Switching to the next scene...")

		# Check if parent exists
		if get_parent():
			print("Parent node found: ", get_parent().name)
		else:
			print("No parent node found!")

		# Check if parent has start_game(), otherwise change the scene manually
		if get_parent() and get_parent().has_method("start_game"):
			print("Calling start_game() from parent...")
			get_parent().start_game()
		else:
			print("WARNING: start_game() is missing in parent! Switching manually...")
			var error = get_tree().change_scene_to_file("res://scenes/part1/layer1.tscn")
			if error != OK:
				print("ERROR: Scene change failed with code ", error)

		queue_free()
