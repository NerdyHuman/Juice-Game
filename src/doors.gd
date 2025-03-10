extends TileMapLayer

func openDoor(key: StaticBody2D, coords: Vector2i):
	key.picked_up_by = null
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(key, "origin", to_global(map_to_local(coords)) - Vector2(360, 6.5), 0.2)
	
	var key_animation_player = key.get_node("Sprite2D/AnimationPlayer") as AnimationPlayer
	key_animation_player.play("key_open")
	
	await key_animation_player.animation_finished
	
	key.queue_free()
	
	set_cell(coords)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
