extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const JUMP_QUEUE_GRACE_PERIOD = 0.1

var isJumpQueued = false
var timeSinceJumpQueued = 0

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
	
	# Handle Dash
	if Input.is_action_just_pressed("dash") and canDash:
		var verticalDirection := Input.get_axis("look-up", "look-down")
		
		# up
		if verticalDirection < 0:
			velocity.y = -400
		
		canDash = false
		
		velocity.x *= 2
		
		# Origin of the raycast, offset by 5 to prevent intentional glitching
		var origin = (position + Vector2(5 * sign(direction), 5 * sign(verticalDirection)))
		var positionOffset = Vector2(200 * sign(direction), 200 * sign(verticalDirection))
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(origin, position + positionOffset)
		var result = space_state.intersect_ray(query)
		
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUART)
		tween.set_ease(Tween.EASE_IN_OUT)
		
		#if get_child(1).get("flip_h"):
		if result:
			tween.tween_property(self, "position", result.position, 0.1)
		else:
			tween.tween_property(self, "position", position + positionOffset, 0.1)
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
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			if tileMapLayer.name == "JumpPads":
				canDash = true
				velocity.y = JUMP_VELOCITY
			if tileMapLayer.name == "Buttons":
				var tilePosition = collider.local_to_map(collider.to_local(collision.get_position()))
				
				collider.executeButton(tilePosition)

	move_and_slide()
	
	if position.x < 500:
		position.x = 500
	if get_parent().to_global(position).y < 0:
		velocity.y = 0
		position.y = get_parent().to_local(Vector2(position.x, 0)).y
	
	if position.y >= 600:
		print("Dead!")
		get_parent().respawnPlayer()
