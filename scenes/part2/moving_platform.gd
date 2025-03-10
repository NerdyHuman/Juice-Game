extends TileMapLayer

var isActive: bool = false
var awaitingDeactivate: bool = false
var awaitingDeactivateTime: int = 0

var time_elapsed: float

var tween: Tween = null

@export
var distance: int

@export
var durationPerDistance: int

func activate() -> void:
	if awaitingDeactivate:
		awaitingDeactivate = false
		return
	
	if isActive:
		return
	
	if tween != null:
		tween.kill()
		tween = null
	
	# calculate the total distance of the path
	var dist = 0
	
	var curve: Curve2D = get_parent().get_parent().curve
	for i in curve.point_count:
		if i == 0:
			continue
		
		var previousPointPosition = curve.get_point_position(i - 1)
		var currentPointPosition = curve.get_point_position(i)
		
		if i == 1:
			previousPointPosition = get_parent().position
		
		dist += currentPointPosition.distance_to(previousPointPosition)
	
	# Each 200px travelled should take 5 seconds.
	tween = get_tree().create_tween()
	tween.tween_property(get_parent(), "progress_ratio", 1, floor(durationPerDistance * (dist / distance)))
	
	isActive = true

func deactivate() -> void:
	if not isActive:
		return
	
	awaitingDeactivateTime = time_elapsed
	awaitingDeactivate = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	
	if awaitingDeactivate and awaitingDeactivateTime + 2 <= time_elapsed:
		if tween != null:
			tween.kill()
			tween = null
		
		tween = get_tree().create_tween()
		tween.tween_property(get_parent(), "progress_ratio", 0, durationPerDistance * get_parent().get("progress_ratio"))
		
		isActive = false
	#if isActive:
		#position.x += 50 * delta
