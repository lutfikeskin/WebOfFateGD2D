extends PanelContainer

## Hand Selection Panel - Allows player to choose cards to keep (Mulligan system)

signal selection_confirmed(kept_cards: Array[Card], discarded_cards: Array[Card])

@onready var title_label: Label = %TitleLabel
@onready var instruction_label: Label = %InstructionLabel
@onready var cards_container: HBoxContainer = %CardsContainer
@onready var confirm_button: Button = %ConfirmButton
@onready var selection_count_label: Label = %SelectionCountLabel

const CARDS_TO_KEEP := 5
const CARDS_TO_DRAW := 6

var available_cards: Array[Card] = []
var selected_cards: Array[Card] = []

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	visible = false

## Show the selection UI with drawn cards
func show_selection(cards: Array[Card]) -> void:
	available_cards = cards
	selected_cards.clear()
	
	# Clear previous
	for child in cards_container.get_children():
		cards_container.remove_child(child)
	
	# Add cards to container
	for card in cards:
		cards_container.add_child(card)
		card.visible = true
		card.disabled = false
		card.is_front_face = true
		
		# Connect click signal
		if not card.card_clicked.is_connected(_on_card_clicked):
			card.card_clicked.connect(_on_card_clicked)
		
		# Auto-select first 5 cards
		if selected_cards.size() < CARDS_TO_KEEP:
			_select_card(card)
	
	_update_ui()
	visible = true

func _on_card_clicked(card: Card) -> void:
	if selected_cards.has(card):
		_deselect_card(card)
	else:
		if selected_cards.size() < CARDS_TO_KEEP:
			_select_card(card)

func _select_card(card: Card) -> void:
	selected_cards.append(card)
	card.position_offset = Vector2(0, -30)
	card.modulate = Color.WHITE
	_update_ui()

func _deselect_card(card: Card) -> void:
	selected_cards.erase(card)
	card.position_offset = Vector2.ZERO
	card.modulate = Color(0.7, 0.7, 0.7)
	_update_ui()

func _update_ui() -> void:
	selection_count_label.text = "%d / %d selected" % [selected_cards.size(), CARDS_TO_KEEP]
	confirm_button.disabled = selected_cards.size() != CARDS_TO_KEEP
	
	if selected_cards.size() == CARDS_TO_KEEP:
		confirm_button.text = "Confirm Selection"
	else:
		var needed = CARDS_TO_KEEP - selected_cards.size()
		confirm_button.text = "Select %d more" % needed

func _on_confirm_pressed() -> void:
	if selected_cards.size() != CARDS_TO_KEEP:
		return
	
	# Determine discarded cards
	var discarded: Array[Card] = []
	for card in available_cards:
		if not selected_cards.has(card):
			discarded.append(card)
	
	# Remove cards from container before emitting (they'll be reparented)
	for card in available_cards:
		if card.get_parent() == cards_container:
			cards_container.remove_child(card)
		# Disconnect our click handler
		if card.card_clicked.is_connected(_on_card_clicked):
			card.card_clicked.disconnect(_on_card_clicked)
	
	visible = false
	selection_confirmed.emit(selected_cards.duplicate(), discarded)
	
	# Clear state
	available_cards.clear()
	selected_cards.clear()
