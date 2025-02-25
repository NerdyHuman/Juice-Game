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

var canSwitchLayers = true

var platform1Visible = false

var isGamePadConnected = false

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

func update_glyphs() -> void:
	# if there's no longer a connected joypad but a gamepad was previously connected
	# basically, update now.
	if Input.get_connected_joypads().size() == 0 and isGamePadConnected:
		isGamePadConnected = false
		var tutorialDirections = get_node("TutorialDirections") as TileMapLayer
		
		for cell in tutorialDirections.get_used_cells():
			var cellAtlasCoords = tutorialDirections.get_cell_atlas_coords(cell)
			
			# the plus sign is not translatable
			if cellAtlasCoords == Vector2i(4, 2):
				continue
			
			# individual keys
			if cellAtlasCoords.y >= 2:
				tutorialDirections.set_cell(cell, 0, Vector2i(0, cellAtlasCoords.y))
			# arrow directions
			else:
				tutorialDirections.set_cell(cell, 0, Vector2i(max(cellAtlasCoords.x - 4, 0), cellAtlasCoords.y))
	# a gamepad is attached but the flag is set to false
	elif Input.get_connected_joypads().size() > 0 and not isGamePadConnected:
		isGamePadConnected = true
		
		# 1 = PlayStation, 2 = Xbox/Generic, 3 = Joycons
		var gamePadType = 2
		
		# TODO: Joycon support
		if Input.get_joy_name(Input.get_connected_joypads()[0]).begins_with("PS"):
			gamePadType = 1
		
		var tutorialDirections = get_node("TutorialDirections") as TileMapLayer
		
		for cell in tutorialDirections.get_used_cells():
			var cellAtlasCoords = tutorialDirections.get_cell_atlas_coords(cell)
			
			# the plus sign is not translatable
			if cellAtlasCoords == Vector2i(4, 2):
				continue
			
			# individual keys
			if cellAtlasCoords.y >= 2:
				tutorialDirections.set_cell(cell, 0, Vector2i(gamePadType, cellAtlasCoords.y))
			# arrow directions
			else:
				tutorialDirections.set_cell(cell, 0, Vector2i(min(cellAtlasCoords.x + 4, 7), cellAtlasCoords.y))

func initialize() -> void:
	for child in Util.get_children_recursive(get_node("Platform1")):
		child.set("visible", platform1Visible)
		child.set("enabled", platform1Visible)
		child.set("collision_enabled", platform1Visible)
	
	get_node("Platform1").set("visible", platform1Visible)
	get_node("Platform1").set("enabled", platform1Visible)
	get_node("Platform1").set("collision_enabled", platform1Visible)

func post_init() -> void:
	if get_node("TutorialPauseArea").overlaps_body(get_node("Player")):
		get_node("Player").isActive = false
