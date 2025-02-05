extends Node2D

const NOISE_AMP = 5
var noise: Noise = FastNoiseLite.new()
var isTransitioning: bool = false
var activePlayer: int = 0
var balance: int = 0

var prices: Dictionary = {"Godot": 90, "Player": 20}
var iconPaths: Dictionary = {"Godot": "res://icon.svg", "Player": "res://player.png"}

# Takes an X value and returns how tall the passage should be
func generateTerrain(x: int):
	var result = (noise.get_noise_1d(x) + 1)/2
	return result * NOISE_AMP

func stopTransitioning():
	get_child(activePlayer).get_node("Camera2D/Label").set("visible", true)
	isTransitioning = false

func activatePlayer():
	get_child(activePlayer).isActive = true

func updateBalance():
	get_child(activePlayer).get_node("Camera2D/Label").set("text", "$" + str(balance))

func giveBalance(amount: int):
	balance += amount
	
	updateBalance()

# Returns a bool, true/false if the user was able to purchase it.
func buyItem(name: String) -> bool:
	if prices[name] <= balance:
		balance -= prices[name]
		updateBalance()
		return true
	
	return false

func showShopUI():
	get_child(activePlayer).isActive = false
	
	var shopUI = load("res://ShopPopup.tscn") as PackedScene
	
	var scene = shopUI.instantiate()
	
	for item in iconPaths:
		var iconPath = iconPaths[item]
		
		scene.addShopItem(item, ImageTexture.create_from_image(Image.load_from_file(iconPath)), prices[item])
	
	scene.connect("tree_exited", activatePlayer)
	
	var camera = get_child(activePlayer).get_node("Camera2D")
	
	camera.add_child(scene)

func switchPlayers():
	if isTransitioning:
		return
	isTransitioning = true
	
	var oldPlayer = get_child(activePlayer)
	oldPlayer.isActive = false
	
	activePlayer = (activePlayer + 1) % 2
	
	var newPlayer = get_child(activePlayer)
	newPlayer.isActive = true
	
	var camera: Node = oldPlayer.get_node("Camera2D")
	camera.get_node("Label").set("visible", false)
	camera.reparent(newPlayer)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(camera, "position", Vector2(0, 0), 1)
	tween.tween_callback(stopTransitioning)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch-player") and get_child(activePlayer).isActive:
		switchPlayers()

func _ready() -> void:
	# just render the balance
	giveBalance(0)
	
	# always the bottom player
	get_child(0).canBreakOrBuild = true
	
	# always the top player
	get_child(1).canBuy = true
	
	get_child(activePlayer).isActive = true
	
	noise.set("seed", randi())
	noise.set("fractal_gain", 5.0)
	
	var terrain = get_child(2) as TileMapLayer
	
	for i in 20:
		# Starting from 4
		var rowLoc = i + 4
		
		# Height must be atleast 2 blocks tall
		var height = floor(generateTerrain(rowLoc) + 2)
		
		for j in height:
			terrain.set_cell(Vector2(rowLoc, (5 - (height + 1)/2) + j))
