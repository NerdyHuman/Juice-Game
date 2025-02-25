extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	
	tween.tween_property($Background.get("theme_override_styles/panel"), "bg_color", Color(0.15, 0.15, 0.15, 1), 2)
	tween.tween_property($Credits, "modulate:a", 1, 2).set_delay(1)
	
	tween.tween_property($Credits, "modulate:r", 0, 2).set_delay(4)
	tween.tween_property($Credits, "modulate:g", 0, 2).set_delay(4)
	tween.tween_property($Credits, "modulate:b", 0, 2).set_delay(4)
	
	tween.tween_property($Background.get("theme_override_styles/panel"), "bg_color", Color(0, 0, 0, 1), 1).set_delay(6)
	tween.tween_property($Credits, "modulate:a", 0, 1).set_delay(6)
	
	tween.tween_property($Background.get("theme_override_styles/panel"), "bg_color", Color(0.15, 0.15, 0.15, 1), 1).set_delay(7)
	tween.tween_property($ThankYou, "modulate:a", 1, 2).set_delay(7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
