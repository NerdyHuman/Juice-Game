extends Node2D

func respawnPlayer() -> void:
	var children = name
	
	get_child(0).set("position", get_child(1).get("position"))
