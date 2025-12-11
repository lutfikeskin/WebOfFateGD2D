##Manages a [CardDeck].
@icon("uid://u56pws80lkxh")
class_name CardDeckManager extends Node

##If [code]true[/code], cards in the deck will be visible.
@export var show_cards: bool = false:
	set(value):
		show_cards = value
		_update_card_visibility()

##The deck resource to initialize cards from on ready.
@export var starting_deck: CardDeck

##If [code]true[/code], the deck will be shuffled on ready.
@export var shuffle_on_ready: bool = true

@export var draw_pile: Node
@export var discard_pile: Node

##Sets necessary 
func setup(deck: CardDeck = starting_deck):
	_setup_piles()
	
	if starting_deck:
		initialize_from_deck(deck)
		if shuffle_on_ready:
			shuffle()


func _setup_piles() -> void:
	if !draw_pile:
		draw_pile = Node.new()
		draw_pile.name = "DrawPile"
		add_child(draw_pile)

	if !discard_pile:
		discard_pile = Node.new()
		discard_pile.name = "DiscardPile"
		add_child(discard_pile)


##Initializes the deck from a CardDeck resource, creating Card instances.
func initialize_from_deck(deck: CardDeck) -> void:
	clear_deck()
	
	for card_resource in deck.cards:
		var card = Card.new(card_resource)
		_connect_card_signals(card)
		add_card_to_draw_pile(card)
	
	_update_card_visibility()

func _connect_card_signals(card: Card) -> void:
	# Use gui_input to detect right clicks
	if not card.gui_input.is_connected(_on_card_gui_input):
		card.gui_input.connect(func(event): _on_card_gui_input(card, event))
	
	# Only use mouse_entered for Audio, NOT tooltip
	if not card.mouse_entered.is_connected(_on_card_mouse_entered):
		card.mouse_entered.connect(func(): _on_card_mouse_entered(card))
	if not card.mouse_exited.is_connected(_on_card_mouse_exited):
		card.mouse_exited.connect(func(): _on_card_mouse_exited(card))

func _on_card_gui_input(card: Card, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Toggle Tooltip
		if has_node("/root/TooltipManager"):
			var tm = get_node("/root/TooltipManager")
			# If this card is already showing tooltip, hide it
			if tm._active_card == card:
				tm.request_hide()
			else:
				tm.request_show(card)

func _on_card_mouse_entered(card: Card) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(1) # 1 is HOVER

func _on_card_mouse_exited(card: Card) -> void:
	# Don't hide tooltip on mouse exit anymore, require explicit toggle or clicking elsewhere
	pass

##Adds a card to the draw pile. [br]If the card is already a child [CardHand] the [member CardHand.remove_card] is used to reparent the card.
func add_card_to_draw_pile(card: Card) -> void:
	# Kill all tweens before reparenting
	card.kill_all_tweens()
	card.is_front_face = false
	
	if card.get_parent():
		if card.get_parent() is CardHand:
			card.get_parent().remove_card(card, draw_pile)
		else:
			card.reparent(draw_pile)
	else:
		draw_pile.add_child(card)

	_handle_card_reparanting(card, draw_pile.global_position if draw_pile is Control else Vector2.ZERO)

##Adds a card to the discard pile. [br]If the card is already a child [CardHand] the [member CardHand.remove_card] is used to reparent the card.
func add_card_to_discard_pile(card: Card) -> void:
	# Kill all tweens before reparenting
	card.kill_all_tweens()
	card.is_front_face = true
	
	if card.get_parent():
		if card.get_parent() is CardHand:
			card.get_parent().remove_card(card, discard_pile)
		else:
			card.reparent(discard_pile)
	else:
		discard_pile.add_child(card)
	
	_handle_card_reparanting(card, discard_pile.global_position if discard_pile is Control else Vector2.ZERO)


func _handle_card_reparanting(card: Card, des_position: Vector2 = Vector2.ZERO):
	card.rotation = 0
	card.tween_position(des_position, .2, true)
	card.visible = show_cards
	card.disabled = true


##Draws a card from the top of the draw pile. Returns null if draw pile is empty.
func draw_card() -> Card:
	# Find the last child that is a Card
	var count = draw_pile.get_child_count()
	for i in range(count - 1, -1, -1):
		var child = draw_pile.get_child(i)
		if child is Card:
			# Store global position before removing
			var stored_global_pos = child.global_position if child is Control else Vector2.ZERO
			
			draw_pile.remove_child(child)
			
			# Restore global position after removing
			if child is Control:
				child.global_position = stored_global_pos
			
			child.visible = true
			child.disabled = false
			child.is_front_face = true
			return child
			
	return null


##Draws multiple cards from the draw pile. Returns an array of cards.
func draw_cards(count: int) -> Array[Card]:
	var drawn_cards: Array[Card] = []
	
	for i in count:
		var card = draw_card()
		if card:
			drawn_cards.append(card)
		else:
			break
	
	return drawn_cards


##Shuffles the draw pile randomly.
func shuffle() -> void:
	var cards_array: Array[Card] = []
	
	for child in draw_pile.get_children():
		if child is Card:
			cards_array.append(child)
	
	# Remove cards to shuffle them
	# NOTE: This only removes them from the tree to re-add them in new order.
	# We must be careful not to touch non-Card children.
	for card in cards_array:
		draw_pile.remove_child(card)
	
	cards_array.shuffle()
	
	# Re-add in shuffled order
	for card in cards_array:
		draw_pile.add_child(card)
		card.position = Vector2.ZERO


##Moves all cards from discard pile back to draw pile.
func reshuffle_discard_into_draw() -> void:
	var cards_to_move: Array[Card] = []
	
	for child in discard_pile.get_children():
		if child is Card:
			cards_to_move.append(child)
	
	for card in cards_to_move:
		add_card_to_draw_pile(card)


##Moves all cards from discard pile to draw pile and shuffles.
func reshuffle_discard_and_shuffle() -> void:
	reshuffle_discard_into_draw()
	shuffle()


##Returns the top card of the draw pile without removing it. Returns null if empty.
func peek_top_card() -> Card:
	var count = draw_pile.get_child_count()
	for i in range(count - 1, -1, -1):
		var child = draw_pile.get_child(i)
		if child is Card:
			return child
	return null


##Returns an array of the top N cards from the draw pile without removing them.
func peek_top_cards(count: int) -> Array[Card]:
	var peeked_cards: Array[Card] = []
	var child_count = draw_pile.get_child_count()
	
	# Iterate backwards to find cards
	for i in range(child_count - 1, -1, -1):
		if peeked_cards.size() >= count:
			break
		var child = draw_pile.get_child(i)
		if child is Card:
			peeked_cards.append(child)
			
	# Reverse to match order (top first)
	# (peeked_cards currently has top card at index 0, which is usually expected)
	return peeked_cards


##Removes a specific card from the draw pile.
func remove_card_from_draw_pile(card: Card) -> bool:
	if card.get_parent() == draw_pile:
		var stored_global_pos = card.global_position if card is Control else Vector2.ZERO
		draw_pile.remove_child(card)
		if card is Control:
			card.global_position = stored_global_pos
		return true
	return false


##Removes a specific card from the discard pile.
func remove_card_from_discard_pile(card: Card) -> bool:
	if card.get_parent() == discard_pile:
		var stored_global_pos = card.global_position if card is Control else Vector2.ZERO
		discard_pile.remove_child(card)
		if card is Control:
			card.global_position = stored_global_pos
		return true
	return false


##Returns the number of cards in the draw pile.
func get_draw_pile_size() -> int:
	var count = 0
	for child in draw_pile.get_children():
		if child is Card:
			count += 1
	return count


##Returns the number of cards in the discard pile.
func get_discard_pile_size() -> int:
	var count = 0
	for child in discard_pile.get_children():
		if child is Card:
			count += 1
	return count


##Returns the total number of cards in both piles.
func get_total_card_count() -> int:
	return get_draw_pile_size() + get_discard_pile_size()


##Clears both draw and discard piles, freeing all cards.
func clear_deck() -> void:
	for child in draw_pile.get_children():
		if child is Card:
			child.queue_free()
	
	for child in discard_pile.get_children():
		if child is Card:
			child.queue_free()


##Returns true if the draw pile is empty.
func is_draw_pile_empty() -> bool:
	return get_draw_pile_size() == 0


##Returns true if the discard pile is empty.
func is_discard_pile_empty() -> bool:
	return get_discard_pile_size() == 0


func _update_card_visibility() -> void:
	if not draw_pile or not discard_pile:
		return
	
	for child in draw_pile.get_children():
		if child is Card:
			child.visible = show_cards
	
	for child in discard_pile.get_children():
		if child is Card:
			child.visible = show_cards
