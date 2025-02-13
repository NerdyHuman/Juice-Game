extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const JUMP_QUEUE_GRACE_PERIOD = 0.1

var isJumpQueued = false
var timeSinceJumpQueued = 0

var coyote = false
var coyoteLastFloor = false
var isJumping = false

var isOnPressurePlate = false
var pressurePlateCoords
var pressurePlateLayer

var canDash = false

func killPlayer() -> void:
	print("Died!")
	get_tree().root.get_node("Root").respawnPlayer()

func killzone_callback(body: Node2D) -> void:
	if body == self:
		killPlayer()

func enableDash() -> void:
	canDash = true
	get_tree().root.get_node("Root").reset_switch_regen_count()

func _physics_process(delta: float) -> void:
	if get_tree().root.get_node("Root").isTransitioning:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		enableDash()
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
		velocity.y = JUMP_VELOCITY
	elif isJumpQueued:
		timeSinceJumpQueued += delta
		if timeSinceJumpQueued > JUMP_QUEUE_GRACE_PERIOD:
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
		get_node("Sprite2D").set("flip_h", false)
	elif direction < 0:
		get_node("Sprite2D").set("flip_h", true)
		
	move_and_slide()
	
	var isOnPressurePlateNow = false
	var currentPressurePlate
	var currentPressurePlateLayer
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			if tileMapLayer.name == "JumpPads":
				velocity.y = JUMP_VELOCITY * 1.5
				enableDash()
				isJumping = true
			if tileMapLayer.name == "Checkpoints":
				var collisionPoint = collision.get_position()
				var collisionPointInMap = collider.local_to_map(collider.to_local(collisionPoint))
				
				if collider.get_cell_atlas_coords(collisionPointInMap) == Vector2i(1, 0):
					collider.set_cell(collisionPointInMap, 0, Vector2i(0, 0))
					
					get_tree().root.get_node("Root").set_spawnpoint(collisionPoint)
			if tileMapLayer.name == "PressurePlates" and collision.get_angle() == 0:
				isOnPressurePlateNow = true
				currentPressurePlateLayer = collider
				
				var collisionPoint = collision.get_position()
				var collisionPointInMap = collider.local_to_map(collider.to_local(collisionPoint))
				
				currentPressurePlate = collisionPointInMap
				
				if collider.get_cell_atlas_coords(collisionPointInMap) == Vector2i(0, 0):
					get_tree().root.get_node("Root").activate_pressure_plate(collisionPointInMap, collider)
			if tileMapLayer.name == "Killables":
				killPlayer()

	if (not isOnPressurePlateNow and isOnPressurePlate) or (currentPressurePlate != pressurePlateCoords and isOnPressurePlate and pressurePlateLayer):
		get_tree().root.get_node("Root").deactivate_pressure_plate(pressurePlateCoords, pressurePlateLayer)
	
	isOnPressurePlate = isOnPressurePlateNow
	pressurePlateCoords = currentPressurePlate
	pressurePlateLayer = currentPressurePlateLayer

	move_and_slide()
	
	if position.x < 500:
		position.x = 500
	if position.y < -450:
		position.y = -450

func _on_coyote_timer_timeout() -> void:
	coyote = false
