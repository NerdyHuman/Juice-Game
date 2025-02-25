extends CharacterBody2D

const JUMP_VELOCITY = -300.0

@export var SPEED = 200.0
@export var JUMP_QUEUE_GRACE_PERIOD = 0.1

var isJumpQueued = false
var timeSinceJumpQueued = 0

var generator_count = 0

var coyote = false
var coyoteLastFloor = false
var isJumping = false

var isOnPressurePlate = false
var pressurePlateCoords
var pressurePlateLayer

# The moving platform the player last activated, used to check if the player is still on it.
var lastMovingPlatform
var lastMovingPlatformCell

var canDash = false
var isActive = false

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
	if get_tree().root.get_node("Root").isTransitioning or not isActive:
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
	
	var activatedMovingPlatform
	var movingPlatformCell
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			var collisionPoint = collision.get_position()
			var collisionPointInMap = collider.local_to_map(collider.to_local(collisionPoint))
			
			if tileMapLayer.name == "JumpPads":
				velocity.y = JUMP_VELOCITY * 1.5
				enableDash()
				isJumping = true
			if tileMapLayer.name == "Checkpoints":
				if collider.get_cell_atlas_coords(collisionPointInMap) == Vector2i(1, 0):
					collider.set_cell(collisionPointInMap, 0, Vector2i(0, 0))
					get_tree().root.get_node("Root").set_spawnpoint(collisionPoint)
			if tileMapLayer.name == "PressurePlates" and collision.get_angle() == 0:
				isOnPressurePlateNow = true
				currentPressurePlateLayer = collider
				
				currentPressurePlate = collisionPointInMap
				
				if collider.get_cell_atlas_coords(collisionPointInMap) == Vector2i(0, 0):
					get_parent().activate_pressure_plate(collisionPointInMap, collider)
			if tileMapLayer.name == "Killables":
				killPlayer()
			if tileMapLayer.name == "Portals":
				get_tree().root.get_node("Root").activate_portal(collisionPointInMap)
			if tileMapLayer.name == "MovingPlatform" and collision.get_angle() == 0:
				# attempt to fix the missing cell
				if collider.get_cell_tile_data(collisionPointInMap) == null:
					for cell in collider.get_surrounding_cells(collisionPointInMap):
						if collider.get_cell_tile_data(cell):
							collisionPointInMap = cell
				
				collider.set_cell(collisionPointInMap, 0, Vector2i(2, 0))
				collider.activate()
				activatedMovingPlatform = collider
				movingPlatformCell = collisionPointInMap
			if tileMapLayer.name == "Doors":
				# attempt to fix the missing cell
				if collider.get_cell_tile_data(collisionPointInMap) == null:
					for cell in collider.get_surrounding_cells(collisionPointInMap):
						if collider.get_cell_tile_data(cell):
							collisionPointInMap = cell
				
				collider.toggle(collisionPointInMap)
			if tileMapLayer.name == "Generators":
				# attempt to fix the missing cell
				if collider.get_cell_tile_data(collisionPointInMap) == null:
					for cell in collider.get_surrounding_cells(collisionPointInMap):
						if collider.get_cell_tile_data(cell):
							collisionPointInMap = cell
				
				generator_count += 1
				collider.set_cell(collisionPointInMap)
			
		elif collider is StaticBody2D:
			var staticBody = collider as StaticBody2D
			
			if staticBody.name == "Key":
				# disable its collision
				staticBody.get_node("CollisionShape2D").disabled = true
				staticBody.picked_up_by = self
				staticBody.is_picked_up = true

	if (not isOnPressurePlateNow and isOnPressurePlate) or (currentPressurePlate != pressurePlateCoords and isOnPressurePlate and pressurePlateLayer):
		get_parent().deactivate_pressure_plate(pressurePlateCoords, pressurePlateLayer)
	
	# if the player is on a new platform
	if activatedMovingPlatform != lastMovingPlatform and activatedMovingPlatform != null and lastMovingPlatform != null:
		lastMovingPlatform.set_cell(lastMovingPlatformCell, 0, Vector2i(0, 0))
		lastMovingPlatform.deactivate()
		
		lastMovingPlatform = activatedMovingPlatform
		lastMovingPlatformCell = movingPlatformCell
	# if the player stepped off the platform
	elif activatedMovingPlatform != lastMovingPlatform and lastMovingPlatform != null:
		if lastMovingPlatform.to_global(lastMovingPlatform.map_to_local(lastMovingPlatformCell)).distance_to(position) > 125:
			lastMovingPlatform.set_cell(lastMovingPlatformCell, 0, Vector2i(0, 0))
			lastMovingPlatform.deactivate()
			
			lastMovingPlatform = activatedMovingPlatform
			lastMovingPlatformCell = movingPlatformCell
	# player is on a new platform
	elif activatedMovingPlatform != lastMovingPlatform and activatedMovingPlatform != null:
		lastMovingPlatform = activatedMovingPlatform
		lastMovingPlatformCell = movingPlatformCell
	
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
