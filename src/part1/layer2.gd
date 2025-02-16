extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

func showPlatform2():
	get_parent().get_node("Layer1").platform2Visible = true
	# layerTwoPlatform1Visible = true
	
func hidePlatform2():
	get_parent().get_node("Layer1").platform2Visible = false
	# layerTwoPlatform1Visible = false

var pressurePlateActivateListeners: Dictionary = {Vector2i(95, 4): showPlatform2}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(95, 4): hidePlatform2}

var platform1Visible = false

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
	for child in Util.get_children_recursive(get_node("Platform1")):
		child.set("visible", platform1Visible)
		child.set("enabled", platform1Visible)
	
	get_node("Platform1").set("visible", platform1Visible)
	get_node("Platform1").set("enabled", platform1Visible)
