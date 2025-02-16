extends Node2D

const NIL_VECTOR2 = Vector2(999, 999)

const UtilRes = preload("res://src/util.gd")
var Util

var activeLayer = 1

# var loadCount = 0

# The amount of times the player had regenerated their Dash ability through switching layers.
# This is capped to prevent players from flying forever.
var playerSwitchRegens = 0

#var layerOnePosition: Vector2 = NIL_VECTOR2
#var layerTwoPosition: Vector2 = NIL_VECTOR2
#
#var layerOneSpawnpoint: Vector2 = NIL_VECTOR2
#var layerTwoSpawnpoint: Vector2 = NIL_VECTOR2
#
#var layerTwoPlatform1Visible: bool = false
#var layerOnePlatform2Visible: bool = false

# The current part, this is inserted into the scene name like this: "[currentScenePart]/layerX.tscn"
var currentScenePart = "part2"

var isTransitioning = false

# portal destinations, these are diff scenes.
var portalDestinations: Dictionary = {Vector2i(178, 15): "part2"}

func get_active_node() -> Node2D:
	if activeLayer == 0:
		return get_node("Layer1")
	return get_node("Layer2")

func activate_portal(coords: Vector2i) -> void:
	if portalDestinations.has(coords):
		currentScenePart = portalDestinations.get(coords)
		
		#layerOnePosition = NIL_VECTOR2
		#layerTwoPosition = NIL_VECTOR2
		
		#layerOneSpawnpoint = NIL_VECTOR2
		#layerTwoSpawnpoint = NIL_VECTOR2
		
		#layerTwoPlatform1Visible = false
		#layerOnePlatform2Visible = false
		
		activeLayer = 1
		
		for child in get_children():
			child.queue_free()
			await child.tree_exited
			
		var loadingScreen = load("res://scenes/loading_screen.tscn") as PackedScene
		var loadingScreenNode = loadingScreen.instantiate()
		add_child(loadingScreenNode)
		move_child(loadingScreenNode, 1)
		
		var twoSecondTimer = get_tree().create_timer(2)
		
		loadLayers()
		
		var player = get_active_node().get_node("Player")
		
		var playerCamera = Camera2D.new()
		playerCamera.name = "Camera"
		
		loadingScreenNode.set("scale", Vector2(1.0, 1.0) / player.get("scale"))
		
		# gross hack to make sure the loading screen is diplayed in full no matter the players scale
		loadingScreenNode.set("position", -((Vector2(0.5, 0.5) / player.get("scale")) * Vector2(1152, 648)))
		
		loadingScreenNode.reparent(playerCamera, false)
		
		player.add_child(playerCamera)
		
		switchLayers()
		
		# serve that beautiful loading screen for a while, the reason its defined in the back is because..
		# in case the loading process actually does take a while for some reason, we shouldn't delay..
		# the loading process unnecessarily.
		await twoSecondTimer.timeout
		
		loadingScreenNode.queue_free()

func reset_switch_regen_count() -> void:
	playerSwitchRegens = 0

# Spawnpoint states don't persist across layer loads, so we have to keep it in the root node.
func set_spawnpoint(spawnPoint: Vector2) -> void:
	#if activeLayer == 0:
		#layerOneSpawnpoint = spawnPoint
	#else:
		#layerTwoSpawnpoint = spawnPoint
	
	get_active_node().get_node("SpawnPoint").set("position", spawnPoint)

func loadLayers() -> void:
	# loadCount += 1
	var layerOne = load("res://scenes/" + currentScenePart + "/layer1.tscn")
	var layerTwo = load("res://scenes/" + currentScenePart + "/layer2.tscn")
	
	var layerOneScene = layerOne as PackedScene
	var layerTwoScene = layerTwo as PackedScene
	
	var layerOneNode = layerOneScene.instantiate()
	var layerTwoNode = layerTwoScene.instantiate()
	
	#if (layerOneSpawnpoint != NIL_VECTOR2):
		#layerOneNode.get_node("SpawnPoint").set("position", layerOneSpawnpoint)
	#if (layerOnePosition == NIL_VECTOR2):
		#layerOneNode.respawnPlayer()
	#else:
		#layerOneNode.get_node("Player").set("position", layerOnePosition)
	
	#if layerOneNode.has_node("Platform2"):
		#var platform2 = layerOneNode.get_node("Platform2")
		#
		#platform2.set("enabled", layerOnePlatform2Visible)
	#
		#for child in get_children_recursive(platform2):
			#child.set("enabled", layerOnePlatform2Visible)
	
	#if (layerTwoSpawnpoint != NIL_VECTOR2):
		#layerTwoNode.get_node("SpawnPoint").set("position", layerTwoSpawnpoint)
	#if (layerTwoPosition == NIL_VECTOR2):
		#layerTwoNode.respawnPlayer()
	#else:
		#layerTwoNode.get_node("Player").set("position", layerTwoPosition)
		
	#if layerTwoNode.has_node("Platform1"):
		#var platform1 = layerTwoNode.get_node("Platform1")
		#
		#platform1.set("enabled", layerTwoPlatform1Visible)
	#
		#for child in get_children_recursive(platform1):
			#child.set("enabled", layerTwoPlatform1Visible)
	
	add_child(layerOneNode, true)
	add_child(layerTwoNode, true)

func respawnPlayer():
	get_node("Layer1").respawnPlayer()
	get_node("Layer2").respawnPlayer()

func switchLayers():
	if isTransitioning:
		return
	isTransitioning = true
	
	#if activeLayer == 0:
		#get_node("Layer1/Player").get("position")
	#elif activeLayer == 1:
		#layerTwoPosition = get_child(get_child_count() - 1).get_node("Player").get("position")
	
	var oldLayer: Node = get_active_node()
	
	activeLayer = (activeLayer + 1) % 2
	
	# loadLayers()
	var newLayer: Node = get_active_node()
	
	if playerSwitchRegens < 2 or oldLayer.get_node("Player").canDash:
		if not oldLayer.get_node("Player").canDash:
			playerSwitchRegens += 1
		newLayer.get_node("Player").canDash = true
	
	newLayer.set("modulate:a", 0)
	
	var camera = oldLayer.get_node("Player/Camera")
	camera.reparent(newLayer.get_node("Player"))
	
	for child in Util.get_children_recursive(newLayer):
		# can it be disabled?
		if child.get("disabled") != null:
			child.set("disabled", false)
			
		if child.get("enabled") != null:
			child.set("enabled", true)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(camera, "position", Vector2(0, 0), 0.5)
	tween.tween_property(oldLayer, "modulate:a", 0, 0.5)
	tween.tween_property(newLayer, "modulate:a", 1, 0.5)
	
	await tween.finished
	
	for child in Util.get_children_recursive(oldLayer):
		# can it be disabled?
		if child.get("disabled") != null:
			child.set("disabled", true)
			
		if child.get("enabled") != null:
			child.set("enabled", false)
	
	oldLayer.get_node("Player").isActive = false
	newLayer.get_node("Player").isActive = true
	
	newLayer.initialize()
	
	#tween.tween_property(oldLayer.get_node("Player/CollisionShape2D"), "disabled", true, 0)
	#tween.tween_property(newLayer.get_node("Player/CollisionShape2D"), "disabled", false, 0)
	
	isTransitioning = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch-layer"):
		switchLayers()
	elif Input.is_action_just_pressed("teleport-second-player"):
		if activeLayer == 0:
			get_node("Layer2/Player").set("position", get_node("Layer1/Player").get("position"))
		elif activeLayer == 1:
			get_node("Layer1/Player").set("position", get_node("Layer2/Player").get("position"))
		
		switchLayers()
		
		get_active_node().get_node("Player").set("velocity:y", 0)

func _ready() -> void:
	Util = UtilRes.new()
	loadLayers()
	
	var playerCamera = Camera2D.new()
	playerCamera.name = "Camera"
	
	get_active_node().get_node("Player").add_child(playerCamera)
	
	switchLayers()
