extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

var pressurePlateActivateListeners: Dictionary = {}
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
	showOrHidePlatform($Platform1, platform1Visible)

#func _physics_process(delta: float) -> void:
	#if $Player in $CantSwitchArea.get_overlapping_bodies() and canSwitchLayers:
		#canSwitchLayers = false
	#elif $Player not in $CantSwitchArea.get_overlapping_bodies() and not canSwitchLayers:
		#canSwitchLayers = true
