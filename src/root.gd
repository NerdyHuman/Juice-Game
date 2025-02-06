extends Node2D

const NIL_VECTOR2 = Vector2(999, 999)

static var activePlayer = 0

static var layerOnePosition: Vector2 = NIL_VECTOR2
static var layerTwoPosition: Vector2 = NIL_VECTOR2

static var isTransitioning = false

func loadLayer(layer: int) -> void:
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
		sceneNode.get_child(0).set("position", layerOnePosition)
	elif layer == 1:
		if (layerTwoPosition == NIL_VECTOR2):
			sceneNode.respawnPlayer()
		sceneNode.get_child(0).set("position", layerTwoPosition)
	
	add_child(sceneNode)

func deleteOldLayer():
	get_child(0).queue_free()
	isTransitioning = false

func switchPlayers():
	if isTransitioning:
		return
	isTransitioning = true
	
	var topPlayer = get_child(0)
	var bottomPlayer = get_child(1)
	
	var camera: Node
	
	# bottom player
	if activePlayer == 0:
		camera = bottomPlayer.get_child(0)
		camera.reparent(topPlayer)
	else:
		camera = topPlayer.get_child(0)
		camera.reparent(bottomPlayer)
	
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position", Vector2i(0, 0), 20)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch-player"):
		switchPlayers()

func _ready() -> void:
	loadLayer(activeLayer)
