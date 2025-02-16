extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

var platform4Visible = false

func showPlatform3():
	get_parent().get_node("Layer1").platform3Visible = true

func hidePlatform3():
	get_parent().get_node("Layer1").platform3Visible = false

var pressurePlateActivateListeners: Dictionary = {Vector2i(53, 20): showPlatform3}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(53, 20): hidePlatform3}

func activate_pressure_plate(coords: Vector2i, pressurePlatesLayer: TileMapLayer) -> void:
	pressurePlatesLayer.set_cell(coords, 0, Vector2i(1, 0))
	
	# call the callable
	if pressurePlateActivateListeners.has(coords):
		pressurePlateActivateListeners.get(coords).call()

func deactivate_pressure_plate(coords: Vector2i, pressurePlatesLayer: TileMapLayer) -> void:
	pressurePlatesLayer.set_cell(coords, 0, Vector2i(0, 0))
	
	# call the callable
	if pressurePlateDeactivateListeners.has(coords):
		pressurePlateDeactivateListeners.get(coords).call()

func respawnPlayer() -> void:
	var children = name
	
	get_node("Player").set("position", get_node("SpawnPoint").get("position"))

func initialize() -> void:
	for child in Util.get_children_recursive(get_node("Platform4")):
		child.set("visible", platform4Visible)
		child.set("enabled", platform4Visible)
	
	get_node("Platform4").set("visible", platform4Visible)
	get_node("Platform4").set("enabled", platform4Visible)
