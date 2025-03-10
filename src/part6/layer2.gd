extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

func movePlayer():
	var target = get_parent().get_node("Layer1/Player")
	
	get_parent().switchLayers()
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, "position", Vector2(3343, 412), 0.5)

var pressurePlateActivateListeners: Dictionary = {Vector2i(5, 15): movePlayer}
var pressurePlateDeactivateListeners: Dictionary = {}

var canSwitchLayers = true

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
	showOrHidePlatform($Platform1, platform1Visible)
