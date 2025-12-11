class_name GameTable extends Control

signal resources_updated(destiny_points: int, chaos: int)
signal story_updated(logs: Array)
signal card_discarded(card: Card)
# signal game_over(reason: String) # Deprecated, use TurnManager
signal weaving_started()
signal weaving_completed()

@export var slots: Array[GameSlot] = []

var _held_card: Card = null
var _player_hand: PlayerHand = null
var _synergy_calculator: SynergyCalculator
@onready var thread_renderer: ThreadRenderer = $ThreadRenderer

# Resources (kept for display sync, but master data is in GameManager ideally)
var destiny_points: int = 0
var chaos: int = 0
const MAX_CHAOS: int = 100

func _ready() -> void:
	# Initialize Logic Classes
	_synergy_calculator = SynergyCalculator.new()
	
	# Locate slots if not manually assigned
	if slots.is_empty():
		for child in get_children():
			if child is GameSlot:
				slots.append(child)
	
	# Register slots with LoomManager
	for slot in slots:
		LoomManager.register_slot(slot)
	
	# Locate player hand
	if get_parent():
		for child in get_parent().get_children():
			if child is PlayerHand:
				_player_hand = child
				break

	# Setup slots
	for i in range(slots.size()):
		var slot = slots[i]
		slot.slot_id = i
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)

	CG.holding_card.connect(_on_holding_card)
	CG.dropped_card.connect(_on_dropped_card)
	
	# Connect TurnManager signals
	TurnManager.weaving_phase_started.connect(_on_weaving_phase_started)
	
	# Sync initial resources
	destiny_points = GameManager.total_dp
	chaos = GameManager.current_chaos
	resources_updated.emit(destiny_points, chaos)

func _on_slot_clicked(slot_id: int) -> void:
	# Interaction blocked during weaving
	if TurnManager.is_busy:
		return
		
	var slot = _get_slot_by_id(slot_id)
	if not slot:
		return
		
	if slot.has_card():
		# Return card to hand
		_return_card_to_hand(slot)
	else:
		# Try to place selected card
		_try_place_selected_card_in_slot(slot)

func _return_card_to_hand(slot: GameSlot) -> void:
	if not _player_hand:
		return
		
	# Get card from slot
	var card = slot.remove_card(null, _player_hand)
	if card:
		# Add card back to hand
		_player_hand.add_card(card)
		LoomManager.notify_card_removed(card)
		_update_visual_feedback()

func _on_slot_hovered(_slot_id: int, _state: bool) -> void:
	# Optional: global hover logic
	pass

func _try_place_selected_card_in_slot(slot: GameSlot) -> void:
	if not _player_hand or _player_hand.selected.is_empty():
		return
		
	var card_to_move = _player_hand.selected[0]
	
	if slot.can_accept_card(card_to_move):
		# Deselect from hand
		_player_hand.toggle_select(card_to_move)
		
		# Place in slot
		slot.place_card(card_to_move)
		LoomManager.notify_card_placed(card_to_move, slot.slot_id)
		_update_visual_feedback()

func _on_holding_card(card: Card) -> void:
	if TurnManager.is_busy: return
	
	_held_card = card
	# Update highlights for all slots
	for slot in slots:
		slot.set_highlight_state(true, false)
		# Force manual check on start to see if we spawned already over a slot
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			slot.set_highlight_state(true, true)

func _process(_delta: float) -> void:
	# Check for drag highlight
	if _held_card:
		var mouse_pos = get_global_mouse_position()
		for slot in slots:
			var hovered = slot.get_global_rect().has_point(mouse_pos)
			slot.set_highlight_state(true, hovered)
		return

	# Check for selection highlight (click-to-place mode)
	if _player_hand and not _player_hand.selected.is_empty():
		var mouse_pos = get_global_mouse_position()
		for slot in slots:
			# Activate highlight mode because we have a selected card ready to place
			var hovered = slot.get_global_rect().has_point(mouse_pos)
			slot.set_highlight_state(true, hovered)
		return
	
	# Default cleanup if nothing happening
	# (Though GameSlot usually handles its own cleanup on mouse exit, 
	# this ensures we clear states if selection is cancelled externally)
	# for slot in slots:
	# 	slot.set_highlight_state(false, false)

func _on_dropped_card() -> void:
	# Reset highlights
	for slot in slots:
		slot.set_highlight_state(false, false)

	if not _held_card:
		return
	
	if TurnManager.is_busy:
		_held_card = null
		return
	
	var mouse_pos = get_global_mouse_position()
	
	for slot in slots:
		if slot.get_global_rect().has_point(mouse_pos):
			if slot.can_accept_card(_held_card):
				# If coming from hand and selected, deselect
				if _player_hand and _player_hand.selected.has(_held_card):
					_player_hand.toggle_select(_held_card)
				
				slot.place_card(_held_card)
				LoomManager.notify_card_placed(_held_card, slot.slot_id)
				_update_visual_feedback()
				break
	
	_held_card = null

func _get_slot_by_id(id: int) -> GameSlot:
	for slot in slots:
		if slot.slot_id == id:
			return slot
	return null

## Helper to get all cards currently in slots (ordered by slot index, null if empty)
func get_all_slot_cards() -> Array[Card]:
	var cards: Array[Card] = []
	for slot in slots:
		cards.append(slot.get_card())
	return cards

func _on_weaving_phase_started() -> void:
	weave_fate()

## Main Weave Fate function - implements Sticky Web mechanic
func weave_fate() -> void:
	# Emit weaving started signal (for visual feedback)
	weaving_started.emit()
	
	# Calculate outcome using SynergyCalculator and LoomManager
	var outcome = _synergy_calculator.calculate_turn_results(LoomManager)
	
	# Update resources
	destiny_points += outcome.dp
	chaos += outcome.chaos
	chaos = clamp(chaos, 0, MAX_CHAOS)
	
	# Emit signal for UI update
	resources_updated.emit(destiny_points, chaos)
	if outcome.has("log") and not outcome.log.is_empty():
		story_updated.emit(outcome.log)
	
	# Handle passive effects from cards remaining on the table
	var passive_results = _synergy_calculator.calculate_passive_effects(LoomManager)
	destiny_points += passive_results.dp
	chaos += passive_results.chaos
	chaos = clamp(chaos, 0, MAX_CHAOS)
	
	# Update resources again after passive effects
	resources_updated.emit(destiny_points, chaos)
	
	# Update GameManager Progress
	GameManager.update_progress(outcome.dp + passive_results.dp, chaos)
	
	# STICKY WEB: Only remove cards that were part of synergies
	var cards_removed_count: int = 0
	for card in outcome.cards_to_remove:
		var slot = _find_slot_with_card(card)
		if slot:
			var removed_card = slot.remove_card()
			if removed_card:
				# Discard the card (add to discard pile)
				# Notify via signal for manager to handle
				print("DEBUG: Discarding card from synergy: ", removed_card.card_data.display_name if removed_card.card_data else removed_card.name)
				card_discarded.emit(removed_card)
				cards_removed_count += 1
				LoomManager.notify_card_removed(removed_card)
	
	# Check for game over conditions
	if chaos >= MAX_CHAOS:
		TurnManager.trigger_game_over("Chaos reached maximum! The Web has snapped under chaos!")
		_update_visual_feedback()
		return
	
	# TANGLED WEB: Fail state - all slots full AND no cards were removed
	var all_full = true
	for slot in slots:
		if not slot.has_card():
			all_full = false
			break
	
	if all_full and cards_removed_count == 0:
		TurnManager.trigger_game_over("Web Tangled! All slots are full and no synergies were formed!")
		_update_visual_feedback()
		return
	
	# Finish Weaving Phase
	weaving_completed.emit()
	_update_visual_feedback()
	
	# Notify TurnManager that we are done
	TurnManager.complete_weaving()

func _find_slot_with_card(card: Card) -> GameSlot:
	for slot in slots:
		if slot.get_card() == card:
			return slot
	return null

func _update_visual_feedback() -> void:
	if not thread_renderer: return
	
	var all_slots = LoomManager.get_all_slots()
	var processed = []
	
	for slot in all_slots:
		var conns = LoomManager.get_connections_for_slot(slot.slot_id)
		for conn in conns:
			var target_id = conn["target_slot"]
			var pair = [min(slot.slot_id, target_id), max(slot.slot_id, target_id)]
			if processed.has(pair): continue
			processed.append(pair)
			
			var active = false
			var target_slot = LoomManager.get_slot(target_id)
			
			if slot.has_card() and target_slot and target_slot.has_card():
				active = _synergy_calculator.check_synergy(slot.get_card(), target_slot.get_card())
			
			thread_renderer.highlight_connection(slot.slot_id, target_id, active)
