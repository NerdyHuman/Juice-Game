extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

var platform4Visible = false
var platform6Visible = false
var platform8Visible = false

func showPlatform3():
	get_parent().get_node("Layer1").platform3Visible = true

func hidePlatform3():
	get_parent().get_node("Layer1").platform3Visible = false

func showPlatform5():
	get_parent().get_node("Layer1").platform5Visible = true

func hidePlatform5():
	get_parent().get_node("Layer1").platform5Visible = false

func showPlatform7():
	get_parent().get_node("Layer1").platform7Visible = true

var pressurePlateActivateListeners: Dictionary = {Vector2i(53, 20): showPlatform3, Vector2i(135, 13): showPlatform5, Vector2i(199, 1): showPlatform7}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(53, 20): hidePlatform3, Vector2i(135, 13): hidePlatform5}

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

func showPlatform(platform: Node):
	for child in Util.get_children_recursive(platform):
		child.set("visible", true)
		child.set("enabled", true)
		child.set("collision_enabled", true)
	
	platform.set("visible", true)
	platform.set("enabled", true)
	platform.set("collision_enabled", true)

func hidePlatform(platform: Node):
	for child in Util.get_children_recursive(platform):
		child.set("visible", false)
		child.set("enabled", false)
		child.set("collision_enabled", false)
	
	platform.set("visible", false)
	platform.set("enabled", false)
	platform.set("collision_enabled", false)

func initialize() -> void:
	if platform4Visible:
		showPlatform($Platform4)
	else:
		hidePlatform($Platform4)
	
	if platform6Visible:
		showPlatform($Platform6)
	else:
		hidePlatform($Platform6)
	
	if platform8Visible:
		showPlatform($Platform8)
	else:
		hidePlatform($Platform8)
