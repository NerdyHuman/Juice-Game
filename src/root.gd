extends Node2D

const NIL_VECTOR2 = Vector2(999, 999)

var activeLayer = 0

var loadCount = 0

var layerOnePosition: Vector2 = NIL_VECTOR2
var layerTwoPosition: Vector2 = NIL_VECTOR2

var isTransitioning = false

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
		if (layerOnePosition == NIL_VECTOR2):
			sceneNode.respawnPlayer()
		else:
			sceneNode.get_node("Player").set("position", layerOnePosition)
	elif layer == 1:
		if (layerTwoPosition == NIL_VECTOR2):
			sceneNode.respawnPlayer()
		else:
			sceneNode.get_node("Player").set("position", layerTwoPosition)
	
	print(loadCount)
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
