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
					
					# Chronicle System: Record this synergy
					if card.card_data is CardData and target_card.card_data is CardData:
						var card_data1 := card.card_data as CardData
						var card_data2 := target_card.card_data as CardData
						ChronicleManager.record_synergy(
							card_data1.id, card_data2.id,
							combo_result,
							thread_type
						)
					
					if combo_result.remove_cards:
						if not cards_to_remove.has(card): cards_to_remove.append(card)
						if not cards_to_remove.has(target_card): cards_to_remove.append(target_card)

	return {
		"dp": total_dp,
		"chaos": total_chaos,
		"cards_to_remove": cards_to_remove,
		"log": log_entries
	}

## Calculate synergy between two cards
func calculate_synergy(card1: CardData, card2: CardData) -> Dictionary:
	if not card1 or not card2:
		return {}
	
	var result = {
		"synergy_found": false,
		"dp_bonus": 0,
		"chaos_change": 0,
		"narrative": "",
		"thread_type": LoomManager.ThreadType.WHITE # Default to WHITE instead of NONE
	}
	
	# Check explicit synergies first
	var synergy_data = _find_explicit_synergy(card1.id, card2.id)
	if synergy_data:
		result.synergy_found = true
		
		# Apply base values
		if synergy_data.is_negative:
			result.dp_bonus = synergy_data.result_dp # Usually negative
			result.chaos_change = synergy_data.result_chaos
		else:
			result.dp_bonus = synergy_data.result_dp
			result.chaos_change = synergy_data.result_chaos
			
		result.narrative = synergy_data.log_message
		
		# Set thread type based on chaos/negative
		if synergy_data.is_negative:
			result.thread_type = LoomManager.ThreadType.RED # Conflict/Danger
		elif synergy_data.result_chaos > 15:
			result.thread_type = LoomManager.ThreadType.RED
		elif synergy_data.result_chaos > 0:
			result.thread_type = LoomManager.ThreadType.GOLD
		else:
			result.thread_type = LoomManager.ThreadType.WHITE # Use WHITE instead of BLUE
			
	# Dynamic Relationship Check (Refinement)
	if ChronicleManager and ChronicleManager.chronicle:
		var rel = ChronicleManager.chronicle.get_relationship(card1.id, card2.id)
		if rel:
			# If negative affinity (Grudge/Rivalry), add Chaos penalty
			if rel.affinity < -0.3:
				result.chaos_change += 5
				if result.narrative == "":
					result.narrative = "Old rivalries flare up!"
				else:
					result.narrative += " (Rivalry intensifies)"
				result.thread_type = LoomManager.ThreadType.RED
			
			# If positive affinity (Bond/Romance), bonus DP
			elif rel.affinity > 0.5:
				result.dp_bonus += 10
				if result.narrative == "":
					result.narrative = "A bond strengthening fate."
				else:
					result.narrative += " (Bond bonus)"
					
	# If no explicit synergy found but we have implicit tag matches
	if not result.synergy_found:
		_check_implicit_synergies(card1, card2, result)
	
	return result

func _find_explicit_synergy(id1: String, id2: String) -> SynergyData:
	var all_synergies = DataManager.get_all_synergies()
	for synergy in all_synergies:
		var match_1 = (id1 == synergy.card_id_1 and id2 == synergy.card_id_2)
		var match_2 = (id1 == synergy.card_id_2 and id2 == synergy.card_id_1)
		if match_1 or match_2:
			return synergy
	return null

func _check_implicit_synergies(card1: CardData, card2: CardData, result: Dictionary) -> void:
	for tag in card1.tags:
		if card2.tags.has(tag):
			result.synergy_found = true
			result.dp_bonus += 10
			
			if result.narrative == "":
				result.narrative = "Threads of %s align." % tag.capitalize()
			else:
				result.narrative += " (%s)" % tag.capitalize()
				
			# Simple implicit logic for thread color
			if tag == "dark" or tag == "chaos":
				result.thread_type = LoomManager.ThreadType.RED
			elif tag == "gold" or tag == "destiny":
				result.thread_type = LoomManager.ThreadType.GOLD
			else:
				result.thread_type = LoomManager.ThreadType.WHITE # Use WHITE instead of BLUE
			return

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
	
	# Use new helper logic for calculation
	var logic_result = calculate_synergy(d1, d2)
	
	if logic_result.synergy_found:
		result.valid = true
		result.dp_bonus = logic_result.dp_bonus
		result.chaos_change = logic_result.chaos_change
		result.remove_cards = true # Most synergies consume cards? Or maybe not.
		# Original code said "result.remove_cards = synergy.remove_cards" for explicit
		# And "result.remove_cards = true" for implicit.
		# Let's keep implicit remove=true for now, but explicit depends on data.
		
		# Re-check explicit for removal flag (optimization: _find_explicit_synergy call is duplicated but safe)
		var exp_syn = _find_explicit_synergy(d1.id, d2.id)
		if exp_syn:
			result.remove_cards = exp_syn.remove_cards
		else:
			result.remove_cards = true
			
		result.log = logic_result.narrative
		
		# Apply thread type modifiers from original code
		match thread_type:
			LoomManager.ThreadType.RED: # VIOLENCE
				result.dp_bonus *= 2
				result.chaos_change += 5
			LoomManager.ThreadType.GOLD: # CHAOS REDUCTION
				result.chaos_change -= 5
			LoomManager.ThreadType.PURPLE: # MAGIC
				result.dp_bonus += 5
				
	return result

func check_synergy(card1: Card, card2: Card) -> bool:
	# Used for visual feedback mostly
	var res = _check_complex_synergy(card1, card2, 0) # Thread type 0 (WHITE) for generic check
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
