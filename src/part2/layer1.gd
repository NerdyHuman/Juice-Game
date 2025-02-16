extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

var platform3Visible = false

func showPlatform4():
	get_parent().get_node("Layer2").platform4Visible = true

func hidePlatform4():
	get_parent().get_node("Layer2").platform4Visible = false

var pressurePlateActivateListeners: Dictionary = {Vector2i(87, 18): showPlatform4}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(87, 18): hidePlatform4}

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
	for child in Util.get_children_recursive(get_node("Platform3")):
		child.set("visible", platform3Visible)
		child.set("enabled", platform3Visible)
		child.set("collision_enabled", platform3Visible)
	
	get_node("Platform3").set("visible", platform3Visible)
	get_node("Platform3").set("enabled", platform3Visible)
	get_node("Platform3").set("collision_enabled", platform3Visible)
