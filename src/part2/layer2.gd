extends Node2D

var platform4Visible = false

func respawnPlayer() -> void:
	var children = name
	
	get_child(0).set("position", get_child(1).get("position"))

func initialize() -> void:
	get_node("Platform4").set("enabled", platform4Visible)
