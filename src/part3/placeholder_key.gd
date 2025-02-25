extends StaticBody2D

@export var targetDoorCoords: Vector2i

var picked_up_by: Node2D

# for the animation
var seconds_elapsed = 0
var origin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	origin = position
	
	# such a bs bug
	get_node("Sprite2D").position = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if picked_up_by != null:
		origin = picked_up_by.get("position") - Vector2(80, 80)
	
	position = origin + Vector2(0, sin(seconds_elapsed * 5) * 25)
	seconds_elapsed += delta
