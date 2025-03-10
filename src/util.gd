extends Node

# https://www.reddit.com/r/godot/comments/40cm3w/comment/idf9vth/
func get_children_recursive(node: Node) -> Array:
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_children_recursive(N))
		else:
			nodes.append(N)
	return nodes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
