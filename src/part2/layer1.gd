extends Node2D

var platform3Visible = false

func respawnPlayer() -> void:
	var children = name
	
	get_node("Player").set("position", get_node("SpawnPoint").get("position"))

func initialize() -> void:
	get_node("Platform3").set("enabled", platform3Visible)
