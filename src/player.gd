extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const JUMP_QUEUE_GRACE_PERIOD = 0.1

var isJumpQueued = false
var timeSinceJumpQueued = 0

var coyote = false
var coyoteLastFloor
var isJumping = false

var canDash = true

func _physics_process(delta: float) -> void:
	if get_tree().root.get_node("Root").isTransitioning:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		# Reset dash
		canDash = true
		isJumping = false
	
	if not is_on_floor() and coyoteLastFloor and not isJumping:
		coyote = true
		$CoyoteTimer.start()
	
	coyoteLastFloor = is_on_floor()

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		isJumpQueued = true
		timeSinceJumpQueued = 0
	
	if isJumpQueued and (is_on_floor() or coyote):
		isJumpQueued = false
		isJumping = true
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
	
	# Handle Dash
	if Input.is_action_just_pressed("dash") and canDash:
		var verticalDirection := Input.get_axis("look-up", "look-down")
		
		canDash = false
		
		get_node("DashSFX").play()
		
		# Origin of the raycast, offset by 5 to prevent intentional glitching
		var origin = (position + Vector2(5 * sign(direction), 5 * sign(verticalDirection)))
		var positionOffset = Vector2(200 * sign(direction), 200 * sign(verticalDirection))
		velocity = positionOffset
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(origin, position + positionOffset)
		var result = space_state.intersect_ray(query)
		
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUART)
		tween.set_ease(Tween.EASE_IN_OUT)
		
		#if get_child(1).get("flip_h"):
		if result:
			tween.tween_property(self, "position", result.position - Vector2(10 * sign(direction), 20 * sign(verticalDirection)), 0.2)
		else:
			tween.tween_property(self, "position", position + positionOffset, 0.2)
		#else:
			#if resultNegative:
				#tween.tween_property(self, "position", resultNegative.position, 0.1)
			#else:
				#tween.tween_property(self, "position", position - positionOffset, 0.1)
	
	if direction > 0:
		get_node("Sprite2D").set("flip_h", true)
	elif direction < 0:
		get_node("Sprite2D").set("flip_h", false)
		
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			if tileMapLayer.name == "JumpPads":
				velocity.y = JUMP_VELOCITY
				canDash = true
				isJumping = true

	move_and_slide()
	
	if position.x < 500:
		position.x = 500
	if position.y < -450:
		position.y = -450
	if position.y >= 600:
		print("Dead!")
		get_parent().respawnPlayer()


func _on_coyote_timer_timeout() -> void:
	coyote = false
