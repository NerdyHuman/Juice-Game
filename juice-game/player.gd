extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_QUEUE_GRACE_PERIOD = 0.1

static var isJumpQueued = false
static var timeSinceJumpQueued = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		isJumpQueued = true
		timeSinceJumpQueued = 0
	
	if isJumpQueued and is_on_floor():
		isJumpQueued = false
		print("timeSinceJumpQueued = ", timeSinceJumpQueued)
		velocity.y = JUMP_VELOCITY
	elif isJumpQueued:
		timeSinceJumpQueued += delta
		if timeSinceJumpQueued > JUMP_QUEUE_GRACE_PERIOD:
			print("Dequeued jump!")
			isJumpQueued = false

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("walk-left", "walk-right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction > 0:
		get_child(1).set("flip_h", true)
	elif direction < 0:
		get_child(1).set("flip_h", false)
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			if tileMapLayer.name == "JumpPads":
				velocity.y = JUMP_VELOCITY * 2

	move_and_slide()
	
	if position.y >= 600:
		print("Dead!")
		get_tree().root.get_child(1).respawnPlayer()
