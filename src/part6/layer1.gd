extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

func showPlatform1():
	get_parent().get_node("Layer2").platform1Visible = true

func hidePlatform1():
	get_parent().get_node("Layer2").platform1Visible = false

var pressurePlateActivateListeners: Dictionary = {Vector2i(205, 9): showPlatform1}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(205, 9): hidePlatform1}

var canSwitchLayers = true

var blocksVisible = false

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

func specialThing1Listener():
	$Player.isActive = false
	
	blocksVisible = true
	initialize()
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Player, "position", Vector2(11412, 875), 0.5)
	await tween.finished
	
	$Player.isActive = true

var specialThingListeners: Dictionary = {Vector2i(147, 27): specialThing1Listener}

func invokeSpecialThing(coords: Vector2i) -> void:
	if specialThingListeners.has(coords):
		specialThingListeners[coords].call()

func initialize() -> void:
	showOrHidePlatform($Blocks, blocksVisible)

#func _physics_process(delta: float) -> void:
	#if $Player in $CantSwitchArea.get_overlapping_bodies() and canSwitchLayers:
		#canSwitchLayers = false
	#elif $Player not in $CantSwitchArea.get_overlapping_bodies() and not canSwitchLayers:
		#canSwitchLayers = true
