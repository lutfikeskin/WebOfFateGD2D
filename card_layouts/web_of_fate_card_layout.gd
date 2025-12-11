extends CardLayout

@onready var card_color: PanelContainer = %CardColor
@onready var texture_rect: TextureRect = %TextureRect
@onready var value_label: Label = %ValueLabel

var res: CardData

func _ready() -> void:
	_update_display()

func _update_display() -> void:
	if not card_resource is CardData:
		return
		
	res = card_resource as CardData
	
	if not is_node_ready():
		return
		
	set_color()
	
	if res.top_texture:
		texture_rect.texture = res.top_texture
	elif res.texture_path and ResourceLoader.exists(res.texture_path):
		texture_rect.texture = load(res.texture_path)
		
	set_text_display()

func set_color():
	if not card_color: return
	
	match res.category:
		CardData.Category.CHARACTER:
			card_color.self_modulate = Color(0.8, 0.8, 1.0) # Blueish
		CardData.Category.ITEM:
			card_color.self_modulate = Color(0.9, 0.9, 0.7) # Yellowish
		CardData.Category.EVENT:
			card_color.self_modulate = Color(0.8, 1.0, 0.8) # Greenish
		CardData.Category.LOCATION:
			card_color.self_modulate = Color(0.9, 0.7, 0.5) # Brownish
		CardData.Category.DISASTER:
			card_color.self_modulate = Color(1.0, 0.6, 0.6) # Reddish
		_:
			card_color.self_modulate = Color.WHITE

func set_text_display():
	if not value_label: return
	
	# Display full name and adjust size
	if res.display_name != "":
		value_label.text = res.display_name
		# Reduce font size to fit if needed
		value_label.add_theme_font_size_override("font_size", 12)
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		value_label.text = ""
