extends Node2D

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

var platform3Visible = false
var platform5Visible = false
var platform7Visible = false

func showPlatform4():
	get_parent().get_node("Layer2").platform4Visible = true

func hidePlatform4():
	get_parent().get_node("Layer2").platform4Visible = false

func showPlatform6():
	get_parent().get_node("Layer2").platform6Visible = true

func hidePlatform6():
	get_parent().get_node("Layer2").platform6Visible = false

func movePlayerBack():
	get_node("Player").isActive = false
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(get_node("Player"), "position", Vector2(12780, 500), 0.4)
	await tween.finished
	
	get_parent().get_node("Layer2").platform8Visible = true
	get_parent().get_node("Layer2/Player").position = Vector2(14300, 80)
	
	get_parent().switchLayers()

var pressurePlateActivateListeners: Dictionary = {Vector2i(87, 18): showPlatform4, Vector2i(176, 7): showPlatform6, Vector2i(175, 16): movePlayerBack}
var pressurePlateDeactivateListeners: Dictionary = {Vector2i(87, 18): hidePlatform4, Vector2i(176, 7): hidePlatform6}

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

func initialize() -> void:
	for child in Util.get_children_recursive(get_node("Platform3")):
		child.set("visible", platform3Visible)
		child.set("enabled", platform3Visible)
		child.set("collision_enabled", platform3Visible)
	
	get_node("Platform3").set("visible", platform3Visible)
	get_node("Platform3").set("enabled", platform3Visible)
	get_node("Platform3").set("collision_enabled", platform3Visible)
	
	for child in Util.get_children_recursive(get_node("Platform5")):
		child.set("visible", platform5Visible)
		child.set("enabled", platform5Visible)
		child.set("collision_enabled", platform5Visible)
	
	get_node("Platform5").set("visible", platform5Visible)
	get_node("Platform5").set("enabled", platform5Visible)
	get_node("Platform5").set("collision_enabled", platform5Visible)
	
	for child in Util.get_children_recursive(get_node("Platform7")):
		child.set("visible", platform7Visible)
		child.set("enabled", platform7Visible)
		child.set("collision_enabled", platform7Visible)
	
	get_node("Platform7").set("visible", platform7Visible)
	get_node("Platform7").set("enabled", platform7Visible)
	get_node("Platform7").set("collision_enabled", platform7Visible)
