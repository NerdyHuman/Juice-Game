extends CharacterBody2D

const JUMP_VELOCITY = -500.0

@export var SPEED = 400.0
@export var JUMP_QUEUE_GRACE_PERIOD = 0.1

var isJumpQueued = false
var timeSinceJumpQueued = 0

var dashTween: Tween = null

var dashesAvailable: int = 1

var crouching: bool = false

var coyote = false
var coyoteLastFloor = false
var isJumping = false

var isOnPressurePlate = false
var pressurePlateCoords
var pressurePlateLayer

const UtilRes = preload("res://src/util.gd")
var Util = UtilRes.new()

# The moving platform the player last activated, used to check if the player is still on it.
var lastMovingPlatform
var lastMovingPlatformCell

var isActive = false

var grabbedKey: StaticBody2D = null

func killPlayer() -> void:
	print("Died!")
	
	isActive = false
	$Camera/PlayerHUD/DeathScreen.start()
	var timer = get_tree().create_timer(0.6)
	await timer.timeout
	
	get_tree().root.get_node("Root").respawnPlayer()
	isActive = true

func killzone_callback(body: Node2D) -> void:
	if body == self:
		killPlayer()

func enableDash() -> void:
	dashesAvailable += 1
	get_tree().root.get_node("Root").reset_switch_regen_count()

func _physics_process(delta: float) -> void:
	if get_tree().root.get_node("Root").isTransitioning or not isActive:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if dashesAvailable != 1:
			dashesAvailable = 0
			enableDash()
		isJumping = false
	
	if not is_on_floor() and coyoteLastFloor and not isJumping:
		coyote = true
		$CoyoteTimer.start()
	
	coyoteLastFloor = is_on_floor()
	
	if Input.is_action_pressed("crouch") and is_on_floor() and not crouching:
		crouching = true
		$Sprite2D.scale.y /= 2
		$CollisionShape2D.scale.y /= 2
		position.y += 50
	if (Input.is_action_just_released("crouch") or not is_on_floor()) and crouching:
		crouching = false
		$Sprite2D.scale.y *= 2
		$CollisionShape2D.scale.y *= 2
		position.y -= 25
	
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
	if Input.is_action_just_pressed("dash") and dashesAvailable > 0:
		var verticalDirection := Input.get_axis("look-up", "look-down")
		
		# Origin of the raycast, offset by 5 to prevent intentional glitching
		var origin = (position + Vector2(5 * sign(direction), 5 * sign(verticalDirection)))
		var positionOffset = Vector2(1 * sign(direction), 1 * sign(verticalDirection))
		
		if positionOffset != Vector2(0, 0):
			positionOffset = positionOffset.normalized() * 250
			
			dashesAvailable -= 1
			
			get_node("DashSFX").play()
		
			velocity = positionOffset
			
			var space_state = get_world_2d().direct_space_state
			
			var query = PhysicsRayQueryParameters2D.create(origin, position + positionOffset)
			query.collision_mask = 1
			
			var result = space_state.intersect_ray(query)
			
			if dashTween != null and dashTween.is_running():
				dashTween.kill()
			
			dashTween = get_tree().create_tween()
			dashTween.set_trans(Tween.TRANS_QUART)
			dashTween.set_ease(Tween.EASE_IN_OUT)
			
			#if get_child(1).get("flip_h"):
			if result:
				dashTween.tween_property(self, "position", result.position - Vector2(10 * sign(direction), 20 * sign(verticalDirection)), 0.2)
			else:
				dashTween.tween_property(self, "position", position + positionOffset, 0.2)
	
	if direction > 0:
		get_node("Sprite2D").set("flip_h", false)
	elif direction < 0:
		get_node("Sprite2D").set("flip_h", true)
	
	if velocity != Vector2(0, 0) and is_on_floor():
		$WalkingParticles.emitting = true
	else:
		$WalkingParticles.emitting = false
	
	move_and_slide()
	
	$Background.position.x = clamp(60 - (position.x - 600) * 0.005, -60, 60)
	$Background.position.y = clamp(0 - (position.y - 350) * 0.005, -60, 60)
	
	var isOnPressurePlateNow = false
	var currentPressurePlate
	var currentPressurePlateLayer
	
	var activatedMovingPlatform
	var movingPlatformCell
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		if collision == null:
			continue
		
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			var collisionPoint = collision.get_position()
			var collisionPointInMap = collider.local_to_map(collider.to_local(collisionPoint))
			
			if tileMapLayer.name == "JumpPads" and abs(collision.get_angle()) <= 1.58:
				velocity.y = JUMP_VELOCITY * 1.5
				if tileMapLayer.get_cell_atlas_coords(collisionPointInMap) == Vector2i(16, 0):
					velocity.y *= 1.5
				enableDash()
				isJumping = true
			if tileMapLayer.name == "PressurePlates" and collision.get_angle() == 0:
				isOnPressurePlateNow = true
				currentPressurePlateLayer = collider
				
				currentPressurePlate = collisionPointInMap
				
				if collider.get_cell_atlas_coords(collisionPointInMap) == Vector2i(0, 0):
					get_parent().activate_pressure_plate(collisionPointInMap, collider)
			if tileMapLayer.name == "Killables":
				if dashTween != null and dashTween.is_running():
					dashTween.kill()
				
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
				# try to find the real collision point if it isnt right
				if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null:
					for cell in tileMapLayer.get_surrounding_cells(collisionPointInMap):
						if tileMapLayer.get_cell_tile_data(cell) != null:
							collisionPointInMap = cell
							break
				
				if grabbedKey != null and grabbedKey.targetDoorCoords == collisionPointInMap:
					#grabbedKey.queue_free()
					#tileMapLayer.set_cell(collisionPointInMap)
					#
					#grabbedKey = null
					tileMapLayer.openDoor(grabbedKey, collisionPointInMap)
		if collider is PhysicsBody2D:
			var body = collider as PhysicsBody2D
			
			if body.name.begins_with("FallingBlock") and collision.get_angle() == 0:
				var timer = get_tree().create_timer(0.2)
				await timer.timeout
				
				body.stepped_on()

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
	
	if position.x < 300:
		position.x = 300

func _on_coyote_timer_timeout() -> void:
	coyote = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	var found: bool = false
	for child in Util.get_children_recursive(get_parent()):
		if child == body:
			found = true
			break
	
	# yes this is required.
	if not found:
		return
	
	if body is TileMapLayer:
		var tileMapLayer = body as TileMapLayer
		
		var collisionPointInMap = tileMapLayer.local_to_map(tileMapLayer.to_local(position))
		
		# attempt to fix the missing cell
		if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null:
			for cell in tileMapLayer.get_surrounding_cells(collisionPointInMap):
				if tileMapLayer.get_cell_tile_data(cell) != null:
					collisionPointInMap = cell
			
			# if checking the sides wasn't enough, then check the diagonals.
			if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null:
				var bottom_left_corner = tileMapLayer.get_neighbor_cell(collisionPointInMap, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER)
				var bottom_right_corner = tileMapLayer.get_neighbor_cell(collisionPointInMap, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)
				var top_left_corner = tileMapLayer.get_neighbor_cell(collisionPointInMap, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)
				var top_right_corner = tileMapLayer.get_neighbor_cell(collisionPointInMap, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER)
				
				if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null and bottom_left_corner != null:
					collisionPointInMap = bottom_left_corner
					
				if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null and bottom_right_corner != null:
					collisionPointInMap = bottom_right_corner
					
				if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null and top_left_corner != null:
					collisionPointInMap = top_left_corner
					
				if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null and top_right_corner != null:
					collisionPointInMap = top_right_corner
		
		# we STILL didn't find the collision point??
		if tileMapLayer.get_cell_tile_data(collisionPointInMap) == null:
			print("Failed to find collision point!")
			return
		
		var collisionPoint = tileMapLayer.to_global(tileMapLayer.map_to_local(collisionPointInMap))
		
		if tileMapLayer.name == "DashRegens":
			$DashRegenSFX.play()
			
			enableDash()
			
			tileMapLayer.set_cell(collisionPointInMap)
			
			var timer = get_tree().create_timer(2)
			await timer.timeout
			
			tileMapLayer.set_cell(collisionPointInMap, 0, Vector2i(0, 0))
		
		if tileMapLayer.name == "Checkpoints":
			if tileMapLayer.get_cell_atlas_coords(collisionPointInMap) == Vector2i(1, 0):
				tileMapLayer.set_cell(collisionPointInMap, 0, Vector2i(0, 0))
				get_tree().root.get_node("Root").set_spawnpoint(collisionPoint)
		
		if tileMapLayer.name == "Chips":
			tileMapLayer.set_cell(collisionPointInMap)
			get_tree().root.get_node("Root").chips += 1
			
			get_node("Camera/PlayerHUD/VBox/HBox/ChipsCounter").text = str(get_tree().root.get_node("Root").chips)
		
		if tileMapLayer.name == "SpecialThings":
			get_parent().invokeSpecialThing(collisionPointInMap)
	elif body is StaticBody2D:
		var staticBody = body as StaticBody2D
		
		if staticBody.name.begins_with("Key"):
			# disable its collision
			staticBody.get_node("CollisionShape2D").set_deferred("disabled", true)
			staticBody.picked_up_by = self
			
			grabbedKey = staticBody
