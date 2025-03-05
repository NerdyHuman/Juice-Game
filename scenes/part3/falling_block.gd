extends RigidBody2D

var falling = false

var origin: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func stepped_on() -> void:
	if falling:
		return
	
	falling = true
	origin = position
	
	freeze = false
	
	var timer = get_tree().create_timer(4)
	await timer.timeout
	
	freeze = true
	
	# so stupid
	var timer2 = get_tree().create_timer(1)
	await timer2.timeout
	
	move_and_collide(origin - position)
	falling = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
