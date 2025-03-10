extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var time_elapsed = 0

var counter = 0

var started = false

func start():
	started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		return
	
	if started and counter >= 32:
		started = false
		counter = 0
		time_elapsed = 0
		return
	
	time_elapsed += delta
	
	if time_elapsed >= 0.04:
		counter += 1
		
		time_elapsed -= 0.04
		
		texture.region = Rect2((1000 * counter) % 32768, 0, 1000, 0)
