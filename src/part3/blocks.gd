extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func toggle_blocks(blocks: TileMapLayer):
	var used_cells = blocks.get_used_cells()
	
	for cell in used_cells:
		var atlas_coords = blocks.get_cell_atlas_coords(cell)
		
		if atlas_coords.x >= 8:
			atlas_coords.x -= 8
		else:
			atlas_coords.x += 8
		
		blocks.set_cell(cell, 0, atlas_coords)

func _on_switch_blocks_timer_timeout() -> void:
	toggle_blocks(get_node("Blocks1"))
	toggle_blocks(get_node("Blocks2"))
