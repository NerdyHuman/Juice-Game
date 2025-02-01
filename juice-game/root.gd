extends Node2D

static var activeLayer = 0

func loadLayer(layer: int) -> void:
	var resource = null
	
	if layer == 0:
		resource = load("res://layer1.tscn")
	else:
		resource = load("res://layer2.tscn")
	
	var scene = resource as PackedScene
	
	add_child(scene.instantiate())

func respawnPlayer() -> void:
	var children = name
	
	get_child(0).set("position", Vector2(625, 320))

func switchLayers():
	get_child(1).queue_free()
	
# activeLayer + 1 is basically the next layer, but to ensure we dont reach "Layer 3", the % 2 limits it to 0 and 1 only.
	activeLayer = (activeLayer + 1) % 2
	
	loadLayer(activeLayer)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch-layer"):
		switchLayers()

func _ready() -> void:
	loadLayer(0)
	
	respawnPlayer()
