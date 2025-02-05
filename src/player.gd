extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const JUMP_QUEUE_GRACE_PERIOD = 0.1

var isJumpQueued = false
var timeSinceJumpQueued = 0
var canBreakOrBuild = false
var canBuy = false
var isActive = false

func _input(_event: InputEvent) -> void:
	if !isActive:
		return
	
	if Input.is_action_just_pressed("mine"):
		if !canBreakOrBuild:
			return
		
		var terrain = get_parent().get_child(2) as TileMapLayer
		var mouseCoords = get_local_mouse_position()
		var mapCoords = terrain.local_to_map(terrain.to_local(to_global(mouseCoords)))
		var tileData = terrain.get_cell_tile_data(mapCoords)
		
		if !tileData:
			return
		
		if !mouseCoords.length() < 30:
			return
		
		terrain.set_cell(mapCoords)
		
		if randi() % 4 == 0:
			get_parent().giveBalance(10)
		
	if Input.is_action_just_pressed("build"):
		if !canBreakOrBuild:
			return
		
		var terrain = get_parent().get_child(2) as TileMapLayer
		var mouseCoords = get_local_mouse_position()
		var mapCoords = terrain.local_to_map(terrain.to_local(to_global(mouseCoords)))
		
		var tileData = terrain.get_cell_tile_data(mapCoords)
		
		if tileData:
			return
		
		# too far away or player will get stuck
		if !mouseCoords.length() < 30 || mouseCoords.length() < 15:
			return
		
		terrain.set_cell(mapCoords, 0, Vector2i(0, 0))
	
	if Input.is_action_just_pressed("buy"):
		if !canBuy:
			return
		
		var shops = get_parent().get_child(3) as TileMapLayer
		var playerCoords = get_global_transform().get_origin()
		var playerMapCoords = shops.local_to_map(shops.to_local(playerCoords))
		
		var _cells = shops.get_used_cells()
		
		var surroundingTiles = shops.get_surrounding_cells(playerMapCoords)
		
		for tile in surroundingTiles:
			var tileData = shops.get_cell_tile_data(tile)
			if tileData:
				print("Shop nearby!")
				
				get_parent().showShopUI()
				
				break

func _physics_process(delta: float) -> void:
	if !isActive:
		return
	
	if get_tree().root.get_child(1).isTransitioning:
		return
	
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
		
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		
		if collider is TileMapLayer:
			var tileMapLayer = collider as TileMapLayer
			
			if tileMapLayer.name == "JumpPads":
				velocity.y = JUMP_VELOCITY

	move_and_slide()
	
	#if position.y >= 600:
		#print("Dead!")
		#get_parent().respawnPlayer()
