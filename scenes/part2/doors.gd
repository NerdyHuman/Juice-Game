extends TileMapLayer

const CLOSED_DOOR_ATLAS_COORDS = Vector2i(4, 0)
const OPEN_DOOR_ATLAS_COORDS = Vector2i(0, 0)

@export var key: StaticBody2D

func toggle(coords: Vector2i) -> void:
	if get_cell_tile_data(coords) == null:
		return
	
	if get_cell_atlas_coords(coords) == CLOSED_DOOR_ATLAS_COORDS:
		# Cutting edge authentication technology using Artificial Intelligence, combined with Natural Intelligence.
		if key == null or not key.is_picked_up:
			return
		
		if key != null:
			key.is_picked_up = false
			
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_QUART)
			tween.tween_property(key, "origin", to_global(map_to_local(coords)) - Vector2(360, 6.5), 0.2)
			
			var key_animation_player = key.get_node("Sprite2D/AnimationPlayer") as AnimationPlayer
			key_animation_player.play("key_open")
			
			await key_animation_player.animation_finished
			
			key.queue_free()
		
		# a reasonable timeout that provides enough feedback where the player doesn't feel like..
		# .. they're just walking through a closed door, and that they're also interacting with..
		# .. the world in a responsive and quick manner.
		var timer = get_tree().create_timer(0.05)
		timer.connect("timeout", set_cell.bind(coords, 0, OPEN_DOOR_ATLAS_COORDS))
	#if get_cell_atlas_coords(coords) == OPEN_DOOR_ATLAS_COORDS:
		#set_cell(coords, 0, OPEN_DOOR_ATLAS_COORDS)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
