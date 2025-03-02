extends TileMapLayer

var seconds_elapsed: float = 0
var origin: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	origin = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = Vector2(origin.x, origin.y + (sin(seconds_elapsed*2.5)*100))
	seconds_elapsed += delta
