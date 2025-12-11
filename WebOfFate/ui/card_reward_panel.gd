extends PanelContainer

signal card_selected(card_data: CardData)
signal skipped()

@onready var cards_container: HBoxContainer = %CardsContainer
@onready var skip_button: Button = $VBoxContainer/SkipButton

# We need a card scene to instantiate for display
# Reusing the existing simple_cards Card class but disabling interaction
var card_scene_script = preload("res://addons/simple_cards/card/card.gd")

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)

func show_rewards(count: int = 3) -> void:
	# Clear previous
	for child in cards_container.get_children():
		child.queue_free()
	
	# Get all available cards from DataManager
	# In a real game, you might filter by rarity or unlock status
	var all_cards = []
	# Assuming DataManager exposes internal dictionary or we iterate known IDs
	# For now, let's use a helper method we should add to DataManager to get random cards
	all_cards = DataManager.get_all_cards_list()
	
	if all_cards.is_empty():
		return
		
	all_cards.shuffle()
	
	for i in range(min(count, all_cards.size())):
		var data = all_cards[i]
		_create_reward_card(data)
		
	visible = true

func _create_reward_card(data: CardData) -> void:
	# Create a visual representation. 
	# Since Card logic is tied to simple_cards, we can use a button with the layout
	var card_display = Button.new()
	card_display.custom_minimum_size = Vector2(150, 210)
	
	# We can reuse the existing card layout scene
	var layout_scene = load("res://card_layouts/web_of_fate_card_layout.tscn")
	var layout = layout_scene.instantiate()
	card_display.add_child(layout)
	
	# Setup layout
	# The layout script expects a "card_resource" property
	layout.card_resource = data
	layout.setup(null, data) # Pass null as card instance since this is just UI
	
	card_display.pressed.connect(func(): _on_card_chosen(data))
	
	cards_container.add_child(card_display)

func _on_card_chosen(data: CardData) -> void:
	card_selected.emit(data)
	visible = false

func _on_skip_pressed() -> void:
	skipped.emit()
	visible = false
