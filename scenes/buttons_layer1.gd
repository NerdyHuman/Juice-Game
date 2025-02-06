extends TileMapLayer

func respawnButton(_buttonCoords: Vector2i):
	#get_tree().root.get_node("Root").get_child(0).respawnPlayer()
	return true

# Any listener takes in a coordinate and returns true if the button should be marked as "Pressed" and no longer interactable
var buttonActions = {Vector2i(15, 4): respawnButton}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func executeButton(coords: Vector2i):
	if buttonActions.has(coords) and buttonActions[coords].call(coords):
		# I accidentally added 2 sprites before this so its technically "source ID 2"
		set_cell(coords, 2, Vector2i(0, 0))
		
		buttonActions.erase(coords)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
