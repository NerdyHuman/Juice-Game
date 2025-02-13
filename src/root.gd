extends Node2D

const NIL_VECTOR2 = Vector2(999, 999)

var activeLayer = 0

var loadCount = 0

# The amount of times the player had regenerated their Dash ability through switching layers.
# This is capped to prevent players from flying forever.
var playerSwitchRegens = 0

var layerOnePosition: Vector2 = NIL_VECTOR2
var layerTwoPosition: Vector2 = NIL_VECTOR2

var layerOneSpawnpoint: Vector2 = NIL_VECTOR2
var layerTwoSpawnpoint: Vector2 = NIL_VECTOR2

var layerTwoPlatform1Visible: bool = false
var layerOnePlatform2Visible: bool = false

var isTransitioning = false

func showPlatform1():
	layerTwoPlatform1Visible = true
	
func hidePlatform1():
	layerTwoPlatform1Visible = false

func showPlatform2():
	layerOnePlatform2Visible = true
	
func hidePlatform2():
	layerOnePlatform2Visible = false

# Pressure Plates
var layerOneActivateListeners: Dictionary = {Vector2i(84, 5): showPlatform1}
var layerOneDeactivateListeners: Dictionary = {Vector2i(84, 5): hidePlatform1}

var layerTwoActivateListeners: Dictionary = {Vector2i(83, 6): showPlatform2}
var layerTwoDeactivateListeners: Dictionary = {Vector2i(83, 6): hidePlatform2}

func activate_pressure_plate(coords: Vector2i, pressurePlatesLayer: TileMapLayer) -> void:
	pressurePlatesLayer.set_cell(coords, 0, Vector2i(1, 0))
	
	# call the callable
	if activeLayer == 0:
		if layerOneActivateListeners.has(coords):
			layerOneActivateListeners.get(coords).call()
	else:
		if layerTwoActivateListeners.has(coords):
			layerTwoActivateListeners.get(coords).call()

func deactivate_pressure_plate(coords: Vector2i, pressurePlatesLayer: TileMapLayer) -> void:
	pressurePlatesLayer.set_cell(coords, 0, Vector2i(0, 0))
	
	# call the callable
	if activeLayer == 0:
		if layerOneDeactivateListeners.has(coords):
			layerOneDeactivateListeners.get(coords).call()
	else:
		if layerTwoDeactivateListeners.has(coords):
			layerTwoDeactivateListeners.get(coords).call()

func reset_switch_regen_count() -> void:
	playerSwitchRegens = 0

# Spawnpoint states don't persist across layer loads, so we have to keep it in the root node.
func set_spawnpoint(spawnPoint: Vector2) -> void:
	if activeLayer == 0:
		layerOneSpawnpoint = spawnPoint
	else:
		layerTwoSpawnpoint = spawnPoint
	
	get_child(0).get_node("SpawnPoint").set("position", spawnPoint)

# https://www.reddit.com/r/godot/comments/40cm3w/comment/idf9vth/
func get_children_recursive(node: Node) -> Array:
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_children_recursive(N))
		else:
			nodes.append(N)
	return nodes

func loadLayer(layer: int) -> void:
	loadCount += 1
	
	var resource = null
	
	if layer == 0:
		resource = load("res://scenes/layer1.tscn")
	else:
		resource = load("res://scenes/layer2.tscn")
	
	var scene = resource as PackedScene
	
	var sceneNode = scene.instantiate()
	
	if layer == 0:
		# disable all pressure plates here
		for k in layerOneDeactivateListeners:
			layerOneDeactivateListeners[k].call()
		
		if (layerOneSpawnpoint != NIL_VECTOR2):
			sceneNode.get_node("SpawnPoint").set("position", layerOneSpawnpoint)
		if (layerOnePosition == NIL_VECTOR2):
			sceneNode.respawnPlayer()
		else:
			sceneNode.get_node("Player").set("position", layerOnePosition)
		
		var platform2 = sceneNode.get_node("Platform2")
		platform2.set("enabled", layerOnePlatform2Visible)
		
		for child in get_children_recursive(platform2):
			child.set("enabled", layerOnePlatform2Visible)
	elif layer == 1:
		# disable all pressure plates here
		for k in layerTwoDeactivateListeners:
			layerTwoDeactivateListeners[k].call()
		
		if (layerTwoSpawnpoint != NIL_VECTOR2):
			sceneNode.get_node("SpawnPoint").set("position", layerTwoSpawnpoint)
		if (layerTwoPosition == NIL_VECTOR2):
			sceneNode.respawnPlayer()
		else:
			sceneNode.get_node("Player").set("position", layerTwoPosition)
			
		var platform1 = sceneNode.get_node("Platform1")
		platform1.set("enabled", layerTwoPlatform1Visible)
		
		for child in get_children_recursive(platform1):
			child.set("enabled", layerTwoPlatform1Visible)
	
	if loadCount == 3:
		sceneNode.get_node("Label").set("text", "Press V to dash!")
	elif loadCount == 4:
		sceneNode.get_node("Label").set("text", "Thanks for reading!")
	# imagine
	elif loadCount == 50:
		sceneNode.get_node("Label").set("text", "You can stop now..")
	elif loadCount > 4:
		sceneNode.get_node("Label").queue_free()
		
	add_child(sceneNode)

func respawnPlayer():
	# Invalidate both to prevent the player from simply switching, then switching again in-place
	layerOnePosition = NIL_VECTOR2
	layerTwoPosition = NIL_VECTOR2
	
	get_child(0).respawnPlayer()

func switchLayers():
	if isTransitioning:
		return
	isTransitioning = true
	
	if activeLayer == 0:
		layerOnePosition = get_child(get_child_count() - 1).get_node("Player").get("position")
	elif activeLayer == 1:
		layerTwoPosition = get_child(get_child_count() - 1).get_node("Player").get("position")
	
	activeLayer = (activeLayer + 1) % 2
	
	loadLayer(activeLayer)
	
	var oldLayer = get_child(get_child_count() - 2)
	var newLayer = get_child(get_child_count() - 1)
	
	if oldLayer.get_node("Player").canDash:
		newLayer.get_node("Player").canDash = true
	elif playerSwitchRegens < 2:
		playerSwitchRegens += 1
		newLayer.get_node("Player").canDash = true
	
	newLayer.set("modulate:a", 0)
	
	var camera = oldLayer.get_node("Player/Camera")
	camera.reparent(newLayer.get_node("Player"))
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(camera, "position", Vector2(0, 0), 0.5)
	tween.tween_property(oldLayer, "modulate:a", 0, 0.5)
	tween.tween_property(newLayer, "modulate:a", 1, 0.5)
	
	await tween.finished
	
	oldLayer.queue_free()
	isTransitioning = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch-layer"):
		switchLayers()
	elif Input.is_action_just_pressed("teleport-second-player"):
		if activeLayer == 0:
			layerTwoPosition = get_child(0).get_node("Player").get("position")
		elif activeLayer == 1:
			layerOnePosition = get_child(0).get_node("Player").get("position")
		
		switchLayers()
		
		get_child(0).get_node("Player").canDash = true
		get_child(0).get_node("Player").set("velocity:y", 0)

func _ready() -> void:
	loadLayer(activeLayer)
	
	var playerCamera = Camera2D.new()
	playerCamera.name = "Camera"
	
	get_child(activeLayer).get_node("Player").add_child(playerCamera)
