extends CardLayout

@onready var card_color: PanelContainer = %CardColor
@onready var texture_rect: TextureRect = %TextureRect
@onready var value_label: Label = %ValueLabel
@onready var category_label: Label = %CategoryLabel
@onready var title_badge: Label = %TitleBadge
@onready var mood_indicator: Label = %MoodIndicator

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
	_update_chronicle_display()

func set_color():
	if not card_color: return
	
	var cat_text = ""
	
	match res.category:
		CardData.Category.CHARACTER:
			card_color.self_modulate = Color(0.8, 0.8, 1.0) # Blueish
			cat_text = "CHAR"
		CardData.Category.ITEM:
			card_color.self_modulate = Color(0.9, 0.9, 0.7) # Yellowish
			cat_text = "ITEM"
		CardData.Category.EVENT:
			card_color.self_modulate = Color(0.8, 1.0, 0.8) # Greenish
			cat_text = "EVENT"
		CardData.Category.LOCATION:
			card_color.self_modulate = Color(0.9, 0.7, 0.5) # Brownish
			cat_text = "LOC"
		CardData.Category.DISASTER:
			card_color.self_modulate = Color(1.0, 0.6, 0.6) # Reddish
			cat_text = "DOOM"
		_:
			card_color.self_modulate = Color.WHITE
			
	if category_label:
		category_label.text = cat_text
	
	# Apply rarity border color
	_apply_rarity_visuals()

func set_text_display():
	if not value_label: return
	
	# Display full name and adjust size
	if res.display_name != "":
		value_label.text = tr(res.display_name)
		# Reduce font size to fit if needed
		value_label.add_theme_font_size_override("font_size", 12)
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		value_label.text = ""

## Update title and mood from Chronicle System
func _update_chronicle_display() -> void:
	# Hide by default
	if title_badge:
		title_badge.visible = false
	if mood_indicator:
		mood_indicator.visible = false
	
	# Check if ChronicleManager is available and has data
	if not Engine.has_singleton("ChronicleManager"):
		# ChronicleManager is autoload, not singleton - check differently
		pass
	
	# Try to get entity state from ChronicleManager
	if ChronicleManager and ChronicleManager.chronicle and res:
		var entity: EntityState = ChronicleManager.chronicle.entity_states.get(res.id)
		if entity:
			# Show title badge if earned
			if title_badge and not entity.earned_titles.is_empty():
				title_badge.text = entity.earned_titles[0]
				title_badge.visible = true
			
			# Show mood indicator
			if mood_indicator:
				mood_indicator.text = _mood_to_emoji(entity.mood)
				mood_indicator.visible = true

func _mood_to_emoji(mood: float) -> String:
	if mood >= 0.5:
		return "😊"
	elif mood >= 0.0:
		return "😐"
	elif mood >= -0.5:
		return "😟"
	else:
		return "😢"

## Apply rarity-based visual effects (border color, glow)
func _apply_rarity_visuals() -> void:
	if not res or not card_color:
		return
	
	var rarity_color := res.get_rarity_color()
	
	# Get or create StyleBox for border color
	var style = card_color.get_theme_stylebox("panel")
	if style and style is StyleBoxFlat:
		var new_style := style.duplicate() as StyleBoxFlat
		new_style.border_color = rarity_color
		
		# Legendary cards get thicker border
		if res.rarity == CardData.Rarity.LEGENDARY:
			new_style.border_width_left = 6
			new_style.border_width_top = 6
			new_style.border_width_right = 6
			new_style.border_width_bottom = 6
		elif res.rarity == CardData.Rarity.EPIC:
			new_style.border_width_left = 5
			new_style.border_width_top = 5
			new_style.border_width_right = 5
			new_style.border_width_bottom = 5
		
		card_color.add_theme_stylebox_override("panel", new_style)
