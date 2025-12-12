class_name GameSlot extends Control

signal card_placed(card: Card, slot_id: int)
signal card_removed(card: Card, slot_id: int)
signal slot_clicked(slot_id: int)
signal slot_hovered(slot_id: int, state: bool)

@export var slot_id: int = -1

# Slot state management
enum SlotState { EMPTY, FILLED, LOCKED }
var state: SlotState = SlotState.EMPTY

# Track which turn the card was placed (for removal restriction)
var placement_turn: int = -1

# Connectivity
var connected_slots: Array[GameSlot] = []

# Visual components
@onready var background: Panel = $Panel
@onready var highlight_rect: ColorRect = $Highlight
@onready var card_container: Control = $CardContainer

func _ready() -> void:
	# Enable mouse filter for click detection
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Initialize visuals
	set_highlight_state(false, false)

func _gui_input(event: InputEvent) -> void:
	# Add manual hover check for drag-drop scenarios where mouse_enter might be consumed
	if CG.current_held_item:
		var global_rect = get_global_rect()
		var mouse_pos = get_global_mouse_position()
		if global_rect.has_point(mouse_pos):
			set_highlight_state(true, true)
		else:
			set_highlight_state(true, false)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(slot_id)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		slot_hovered.emit(slot_id, true)
		if CG.current_held_item: # Check if dragging a card
			set_highlight_state(true, true)
	elif what == NOTIFICATION_MOUSE_EXIT:
		slot_hovered.emit(slot_id, false)
		if CG.current_held_item:
			set_highlight_state(true, false)
		else:
			set_highlight_state(false, false)

# --- Logic API ---

func has_card() -> bool:
	return card_container.get_child_count() > 0

func get_card() -> Card:
	if has_card():
		return card_container.get_child(0) as Card
	return null

func can_accept_card(_card: Card) -> bool:
	# Check both state and actual container content for safety
	return not has_card() and state != SlotState.LOCKED

func place_card(card: Card, turn_number: int = -1) -> void:
	if has_card():
		push_warning("Attempted to place card in a filled slot (Slot ID: %d)" % slot_id)
		return

	# If card has a parent, remove from there properly (if it's a CardHand or another Slot)
	var parent = card.get_parent()
	if parent:
		# Check signature of remove_card to match CardHand or GameSlot expectations
		if parent.has_method("remove_card"):
			# CardHand signature: remove_card(card: Card, new_parent: Node = null)
			# GameSlot signature: remove_card(card: Card = null, new_parent: Node = null) -> Card
			# We need to make sure GameSlot supports this signature too if we move between slots.
			parent.remove_card(card, card_container)
		else:
			card.reparent(card_container)
	else:
		card_container.add_child(card)
	
	# Kill any tweens from CardHand or drag logic that might fight us
	if card.has_method("kill_all_tweens"):
		card.kill_all_tweens()
	
	# Use anchors to center the card reliably, even if size is not yet updated
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.position = Vector2.ZERO
	card.rotation = 0
	card.scale = Vector2.ONE
	card.position_offset = Vector2.ZERO # Important for CardHand reset
	
	# Update internal card state if needed (stop drag)
	card.holding = false
	card._released = true
	
	# Set mouse filter to PASS so clicks can go through to the slot
	# This allows slot clicks to work, but card can still be interacted with this turn
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.disabled = false  # Enable interaction for this turn
	
	# Track which turn this card was placed (for removal restriction)
	if turn_number >= 0:
		placement_turn = turn_number
	else:
		placement_turn = GameManager.turn_count
	
	# Visual updates
	set_highlight_state(false, false)
	state = SlotState.FILLED
	
	card_placed.emit(card, slot_id)

# Modified signature to be compatible with CardHand's expected interface if needed
func remove_card(card: Card = null, new_parent: Node = null, force: bool = false) -> Card:
	if not has_card():
		return null
	
	# If card is not specified, take the current one
	var target_card = card if card else get_card()
	if target_card != get_card():
		return null # Card not in this slot
	
	# Check if card can be removed (only if placed this turn, or if forced)
	if not force and placement_turn >= 0:
		var current_turn = GameManager.turn_count
		if placement_turn != current_turn:
			# Card was placed in a previous turn, cannot be removed
			return null
		
	if new_parent:
		target_card.reparent(new_parent)
	else:
		card_container.remove_child(target_card)
	
	# Reset mouse filter to STOP (default) so it can be clicked/dragged normally in hand
	target_card.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Reset anchors to Top-Left for CardHand or other containers that expect manual positioning
	target_card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	
	# Reset placement tracking
	placement_turn = -1
	state = SlotState.EMPTY
	card_removed.emit(target_card, slot_id)
	
	return target_card

## Check if the card in this slot can be removed (only if placed this turn)
func can_remove_card() -> bool:
	if not has_card():
		return false
	
	# If placement_turn is -1, it means locked (weave sonrası kilitli)
	if placement_turn < 0:
		return false
	
	var current_turn = GameManager.turn_count
	return placement_turn == current_turn

## Lock the card in this slot (after weave, card cannot be interacted with)
func lock_card() -> void:
	if not has_card():
		return
	
	var card = get_card()
	if not card:
		return
	
	# Disable all interaction - card becomes non-interactive
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore all mouse events
	card.disabled = true  # Disable button functionality
	card.undraggable = true  # Prevent dragging (Card class has this property)
	card.holding = false  # Stop any ongoing drag
	card._released = true  # Mark as released
	
	# Kill any active tweens
	if card.has_method("kill_all_tweens"):
		card.kill_all_tweens()
	
	# Mark as locked (placement_turn = -1 means locked)
	placement_turn = -1

# --- Visual Feedback ---

func set_highlight_state(active: bool, hovered: bool):
	if not highlight_rect: return

	# Logic adapted from 3D script for 2D visual feedback
	
	# If not active (no drag happening) and not hovered, hide
	if not active and not hovered:
		highlight_rect.visible = false
		return

	highlight_rect.visible = true
	
	if hovered:
		if has_card():
			# Different color if card can be removed vs locked
			if can_remove_card():
				highlight_rect.color = Color(1, 0.5, 0, 0.5) # Orange if removable
			else:
				highlight_rect.color = Color(1, 0, 0, 0.5) # Red if locked (cannot remove)
		else:
			highlight_rect.color = Color(0, 1, 0, 0.5) # Green if empty (valid)
	elif active:
		if not has_card():
			highlight_rect.color = Color(1, 1, 1, 0.2) # Faint White
		else:
			highlight_rect.visible = false # Hide if full and not hovering
