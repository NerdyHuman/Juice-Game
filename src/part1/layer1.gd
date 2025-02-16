extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

func showPlatform1():
	get_parent().get_node("Layer2").platform1Visible = true
	# layerTwoPlatform1Visible = true
	
func hidePlatform1():
	get_parent().get_node("Layer2").platform1Visible = false
	# layerTwoPlatform1Visible = false

var pressurePlateActivateListeners: Dictionary = {Vector2i(84, 5): showPlatform1}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(84, 5): hidePlatform1}

var platform2Visible = false

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
	for child in Util.get_children_recursive(get_node("Platform2")):
		child.set("visible", platform2Visible)
		child.set("enabled", platform2Visible)
	
	get_node("Platform2").set("visible", platform2Visible)
	get_node("Platform2").set("enabled", platform2Visible)
