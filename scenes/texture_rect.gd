extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var time_elapsed = 0

var counter = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	
	if time_elapsed >= 0.02:
		counter += 1
		time_elapsed -= 0.02
		
		texture.region = Rect2((341 * counter) % 16368, 0, 341, 0)
