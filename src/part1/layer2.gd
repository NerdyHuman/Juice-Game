extends Node2D

var platform1Visible = false

func respawnPlayer() -> void:
	var children = name
	
	get_node("Player").set("position", get_node("SpawnPoint").get("position"))

func initialize() -> void:
	get_node("Platform1").set("enabled", platform1Visible)
