class_name SynergyCalculator extends RefCounted

# Calculates DP and Chaos changes based on the loom state.

func calculate_turn_results(loom_manager: Node) -> Dictionary:
	var total_dp: int = 0
	var total_chaos: int = 0
	var cards_to_remove: Array[Card] = []
	var log_entries: Array[String] = []
	
	var slots = loom_manager.get_all_slots()
	var processed_connections: Array = []
	
	# 1. Base Card Values
	for slot in slots:
		if slot.has_card():
			var card = slot.get_card()
			if card.card_data is CardData:
				var data = card.card_data as CardData
				total_dp += data.base_dp
				total_chaos += data.base_chaos
				
				# Legacy support (kept for now, but should be removed later if CardData.value is gone)
				if data.base_dp == 0 and data.get("value") != null and data.value > 0:
					total_dp += data.value
					total_chaos += floor(data.value / 2.0)
	
	# 2. Connection Logic (Threads)
	for slot in slots:
		if not slot.has_card():
			continue
			
		var slot_id = slot.slot_id
		var card = slot.get_card()
		var connections = loom_manager.get_connections_for_slot(slot_id)
		
		for conn in connections:
			var target_id = conn["target_slot"]
			
			# Avoid double counting
			var conn_key = [min(slot_id, target_id), max(slot_id, target_id)]
			if processed_connections.has(conn_key):
				continue
			processed_connections.append(conn_key)
			
			var target_slot = loom_manager.get_slot(target_id)
			if target_slot and target_slot.has_card():
				var target_card = target_slot.get_card()
				var thread_type = conn["type"]
				
				# Check Specific Combos & Synergies
				var combo_result = _check_complex_synergy(card, target_card, thread_type)
				
				if combo_result.valid:
					total_dp += combo_result.dp_bonus
					total_chaos += combo_result.chaos_change
					if combo_result.log != "":
						log_entries.append(combo_result.log)
					
					if combo_result.remove_cards:
						if not cards_to_remove.has(card): cards_to_remove.append(card)
						if not cards_to_remove.has(target_card): cards_to_remove.append(target_card)

	return {
		"dp": total_dp,
		"chaos": total_chaos,
		"cards_to_remove": cards_to_remove,
		"log": log_entries
	}

# Checks for specific named combinations or tag-based synergies
func _check_complex_synergy(card1: Card, card2: Card, thread_type: int) -> Dictionary:
	var result = {
		"valid": false,
		"dp_bonus": 0,
		"chaos_change": 0,
		"remove_cards": false,
		"log": ""
	}
	
	if not (card1.card_data is CardData and card2.card_data is CardData):
		return result
		
	var d1 = card1.card_data as CardData
	var d2 = card2.card_data as CardData
	var id1 = d1.id
	var id2 = d2.id
	
	# --- SPECIFIC COMBOS (Data Driven) ---
	var all_synergies = DataManager.get_all_synergies()
	
	for synergy in all_synergies:
		# Check if this synergy matches the current pair (unordered)
		var match_1 = (id1 == synergy.card_id_1 and id2 == synergy.card_id_2)
		var match_2 = (id1 == synergy.card_id_2 and id2 == synergy.card_id_1)
		
		if match_1 or match_2:
			result.valid = true
			result.dp_bonus = synergy.result_dp
			result.chaos_change = synergy.result_chaos
			result.remove_cards = synergy.remove_cards
			result.log = tr(synergy.log_message)
			return result

	# --- GENERAL TAG SYNERGIES ---
	
	# Default synergy: Matching Tags
	for tag in d1.tags:
		if d2.tags.has(tag):
			result.valid = true
			result.dp_bonus = 10
			result.remove_cards = true
			result.log = tr("LOG_SYNERGY_FORMED") % [tr(d1.display_name), tr(d2.display_name), tr(tag.capitalize())]
			
			# Thread Modifiers for generic synergy
			match thread_type:
				1: # RED / VIOLENCE
					result.dp_bonus *= 2
					result.chaos_change += 5
				2: # GOLD / CHAOS REDUCTION
					result.chaos_change -= 5
				3: # PURPLE / MAGIC
					result.dp_bonus += 5
					
			return result

	return result

func check_synergy(card1: Card, card2: Card) -> bool:
	# Used for visual feedback mostly
	var res = _check_complex_synergy(card1, card2, 0) # Thread type 0 for generic check
	return res.valid

# To be called by GameTable on turn start/end
func calculate_passive_effects(loom_manager: Node) -> Dictionary:
	var passive_chaos: int = 0
	var passive_dp: int = 0
	
	for slot in loom_manager.get_all_slots():
		if slot.has_card():
			var card = slot.get_card()
			if card.card_data is CardData:
				var d = card.card_data
				
				# Cursed Ring: +5 Chaos per turn
				if d.id == "cursed_ring":
					passive_chaos += 5
				
				# Volcano: +10 Chaos per turn
				if d.id == "volcano":
					passive_chaos += 10
					passive_dp += 10
					
	return {"dp": passive_dp, "chaos": passive_chaos}
