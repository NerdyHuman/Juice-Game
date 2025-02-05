extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func exit() -> void:
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "modulate:a", 0, 0.25).finished
	queue_free()

func _input(_input: InputEvent) -> void:
	if Input.is_action_just_pressed("exit-menu"):
		exit()

func onButtonPress(name: String):
	if get_node("/root/NewRoot").buyItem(name):
		print(name + " purchased!")
		exit()

func addShopItem(name: String, icon: ImageTexture, price: int):
	var vBoxContainer = get_node("MarginContainer/VBoxContainer")
	
	var hBoxContainer: HBoxContainer
	
	# If there's already an HBoxContainer with less than 3 children, use that instead
	if vBoxContainer.get_child_count() > 1 and vBoxContainer.get_child(vBoxContainer.get_child_count() - 1).get_child_count() < 3:
		hBoxContainer = vBoxContainer.get_child(vBoxContainer.get_child_count() - 1)
	else:
		hBoxContainer = HBoxContainer.new()
	
	var button = Button.new()
	
	button.text = name
	button.icon = icon
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.expand_icon = true
	
	var priceTag = Label.new()
	priceTag.text = str(price)
	priceTag.modulate.r = 100
	priceTag.modulate.g = 155
	priceTag.modulate.b = 100
	
	button.add_child(priceTag)
	button.connect("pressed", Callable(self, "onButtonPress").bind(name))
	
	hBoxContainer.add_child(button)
	
	vBoxContainer.add_child(hBoxContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
