extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

func showPlatform1():
	get_parent().get_node("Layer1").platform1Visible = true

func hidePlatform1():
	get_parent().get_node("Layer1").platform1Visible = false

var pressurePlateActivateListeners: Dictionary = {Vector2i(142, 4): showPlatform1}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(142, 4): hidePlatform1}

var canSwitchLayers = true

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

func showOrHidePlatform(platform: Node, visible: bool):
	for child in Util.get_children_recursive(platform):
		child.set("visible", visible)
		child.set("enabled", visible)
		child.set("collision_enabled", visible)
	
	platform.set("visible", visible)
	platform.set("enabled", visible)
	platform.set("collision_enabled", visible)

func initialize() -> void:
	pass
