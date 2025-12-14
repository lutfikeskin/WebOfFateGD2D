extends Node

## Autoload: ChronicleManager
## Central manager for the Chronicle System - tracks emergent narratives.

signal memory_created(memory: MemoryEntry)
signal arc_started(arc: StoryArc)
signal arc_progressed(arc: StoryArc, old_phase: StoryArc.ArcPhase)
signal arc_resolved(arc: StoryArc)
signal entity_title_earned(card_id: String, title: String)

## The active chronicle data for the current run
var chronicle: ChronicleData

func _ready() -> void:
	chronicle = ChronicleData.new()

## Start a fresh chronicle for a new run
func start_new_chronicle() -> void:
	chronicle = ChronicleData.new()
	chronicle.run_start_time = int(Time.get_unix_time_from_system())
	print("ChronicleManager: New chronicle started.")

## Get or create an entity state for a card
func get_or_create_entity(card_id: String) -> EntityState:
	return chronicle.get_or_create_entity(card_id)

## Record a synergy event between two cards
func record_synergy(
	card1_id: String,
	card2_id: String,
	synergy_result: Dictionary,
	thread_type: int
) -> void:
	var dp: int = synergy_result.get("dp_bonus", 0)
	var chaos: int = synergy_result.get("chaos_change", 0)
	
	# Update entity states
	var entity1 := get_or_create_entity(card1_id)
	var entity2 := get_or_create_entity(card2_id)
	
	entity1.synergies_formed += 1
	entity2.synergies_formed += 1
	
	if not entity1.synergy_partners.has(card2_id):
		entity1.synergy_partners.append(card2_id)
	if not entity2.synergy_partners.has(card1_id):
		entity2.synergy_partners.append(card1_id)
	
	if dp > entity1.highest_dp_contribution:
		entity1.highest_dp_contribution = dp
	if dp > entity2.highest_dp_contribution:
		entity2.highest_dp_contribution = dp
	
	# Adjust mood
	entity1.adjust_mood(true, dp)
	entity2.adjust_mood(true, dp)
	
	# Check for new titles
	_check_entity_titles(entity1, card1_id)
	_check_entity_titles(entity2, card2_id)
	
	# Update relationship
	var rel := chronicle.get_or_create_relationship(card1_id, card2_id)
	var narrative := _generate_synergy_narrative(card1_id, card2_id, rel, thread_type)
	rel.record_interaction(true, thread_type, narrative)
	
	# Add bonds
	if not entity1.bonds.has(card2_id):
		entity1.bonds.append(card2_id)
	if not entity2.bonds.has(card1_id):
		entity2.bonds.append(card1_id)
	
	# Create memory
	var memory := MemoryEntry.create_synergy_memory(
		card1_id, card2_id,
		GameManager.turn_count,
		0, # Run phase / Chapter
		thread_type,
		dp, chaos,
		narrative
	)
	chronicle.add_memory(memory)
	chronicle.total_synergies += 1
	
	# Check for high DP moment
	if dp >= 50:
		var high_dp_memory := MemoryEntry.create_high_dp_memory(
			[card1_id, card2_id],
			GameManager.turn_count,
			0, # Run phase
			dp
		)
		high_dp_memory.narrative_fragment = "A legendary moment! %s and %s wove destiny worth %d points!" % [
			_get_card_display_name(card1_id),
			_get_card_display_name(card2_id),
			dp
		]
		chronicle.add_memory(high_dp_memory)
	
	memory_created.emit(memory)
	
	# Check for story arc triggers
	_check_arc_triggers(card1_id, card2_id, synergy_result, thread_type)
	
	print("ChronicleManager: Recorded synergy between %s and %s (DP: %d, Chaos: %d)" % [card1_id, card2_id, dp, chaos])

## Record when a card is played on the loom
func record_card_played(card_id: String) -> void:
	var entity := get_or_create_entity(card_id)
	entity.times_played += 1

## Record when a synergy fails (cards adjacent but no synergy)
func record_synergy_failure(card1_id: String, card2_id: String) -> void:
	var entity1 := get_or_create_entity(card1_id)
	var entity2 := get_or_create_entity(card2_id)
	
	entity1.tragic_encounters += 1
	entity2.tragic_encounters += 1
	
	entity1.adjust_mood(false, 0)
	entity2.adjust_mood(false, 0)
	
	# Update relationship negatively
	var rel := chronicle.get_or_create_relationship(card1_id, card2_id)
	rel.record_interaction(false, 0)

## Record near-death experience (chaos near max)
func record_near_death(current_chaos: int, max_chaos: int) -> void:
	if current_chaos >= max_chaos - 10:
		var memory := MemoryEntry.create_near_death_memory(
			GameManager.turn_count,
			0, # Run phase
			current_chaos,
			max_chaos
		)
		chronicle.add_memory(memory)
		
		if current_chaos > chronicle.peak_chaos:
			chronicle.peak_chaos = current_chaos
		
		memory_created.emit(memory)

# record_chapter_complete removed

## Record run end (victory or defeat)
func record_run_end(is_victory: bool, reason: String) -> void:
	var memory := MemoryEntry.new()
	memory.type = MemoryEntry.MemoryType.RUN_ENDED
	memory.chapter = 0 # Single Run
	memory.turn = chronicle.total_turns
	memory.narrative_fragment = reason
	memory.timestamp = int(Time.get_unix_time_from_system())
	chronicle.add_memory(memory)
	
	# Resolve all arcs
	for arc in chronicle.active_arcs:
		arc.resolve(is_victory)
		chronicle.completed_arcs.append(arc)
	chronicle.active_arcs.clear()
	
	memory_created.emit(memory)

## Increment turn counter
func tick_turn() -> void:
	chronicle.total_turns += 1

## Generate a chronicle summary for end-of-run display
func get_chronicle_summary() -> String:
	if chronicle.memories.is_empty():
		return "No tales were woven in this run."
	
	var summary := "# The Chronicle\n\n"
	
	# Opening
	summary += "In the age of the Loom, a story unfolded across %d turns.\n\n" % [
		chronicle.total_turns
	]
	
	# Notable characters
	var notable_entities := _get_notable_entities()
	if not notable_entities.is_empty():
		summary += "## The Cast\n"
		for card_id in notable_entities:
			var entity: EntityState = chronicle.entity_states[card_id]
			var card_name := _get_card_display_name(card_id)
			if not entity.earned_titles.is_empty():
				card_name = "%s %s" % [card_name, entity.earned_titles[0]]
			summary += "- **%s** - %d synergies, mood: %s\n" % [
				card_name,
				entity.synergies_formed,
				_mood_to_text(entity.mood)
			]
		summary += "\n"
	
	# Notable relationships
	var notable_rels := chronicle.get_notable_relationships()
	if not notable_rels.is_empty():
		summary += "## Bonds Forged\n"
		for rel in notable_rels.slice(0, 3): # Top 3
			var name_a := _get_card_display_name(rel.card_id_a)
			var name_b := _get_card_display_name(rel.card_id_b)
			summary += "- **%s & %s** - %s (%d encounters)\n" % [
				name_a, name_b, rel.get_status().replace("_", " ").capitalize(), rel.interaction_count
			]
		summary += "\n"
	
	# Key moments
	var key_memories := _get_key_memories()
	if not key_memories.is_empty():
		summary += "## Key Moments\n"
		for memory in key_memories:
			summary += "- %s\n" % memory.narrative_fragment
		summary += "\n"
	
	# Completed arcs
	if not chronicle.completed_arcs.is_empty():
		summary += "## Story Arcs\n"
		for arc in chronicle.completed_arcs:
			var protagonist := _get_card_display_name(arc.protagonist_id)
			summary += "- **%s** starring %s - %s\n" % [
				arc.get_arc_name(),
				protagonist,
				arc.resolution_type.capitalize()
			]
		summary += "\n"
	
	# Statistics
	summary += "## Final Tally\n"
	summary += "- Total Synergies: %d\n" % chronicle.total_synergies
	summary += "- Peak Chaos: %d\n" % chronicle.peak_chaos
	summary += "- Highest Single DP: %d\n" % chronicle.highest_single_dp
	
	return summary

## Helper: Check and emit title events
func _check_entity_titles(entity: EntityState, card_id: String) -> void:
	var new_title := entity.check_titles()
	if new_title != "":
		entity_title_earned.emit(card_id, new_title)
		print("ChronicleManager: %s earned title '%s'" % [card_id, new_title])

## Helper: Generate narrative for a synergy
func _generate_synergy_narrative(card1_id: String, card2_id: String, rel: RelationshipData, thread_type: int) -> String:
	var name1 := _get_card_display_name(card1_id)
	var name2 := _get_card_display_name(card2_id)
	
	# Check relationship status for context
	if rel.interaction_count == 0:
		# First meeting
		return "For the first time, %s and %s wove their fates together." % [name1, name2]
	elif rel.affinity >= 0.5:
		# Strong bond
		return "The legendary bond between %s and %s struck once more." % [name1, name2]
	elif rel.affinity <= -0.3:
		# Tension
		return "Despite their history, %s and %s were forced to cooperate." % [name1, name2]
	else:
		# Normal
		var thread_desc := ""
		match thread_type:
			1: thread_desc = "through violence and blood"
			2: thread_desc = "under fortune's golden light"
			3: thread_desc = "shrouded in mystical energies"
			_: thread_desc = "upon the strands of fate"
		return "%s and %s connected %s." % [name1, name2, thread_desc]

## Helper: Get card display name from DataManager
func _get_card_display_name(card_id: String) -> String:
	var card_data = DataManager.get_card_data(card_id)
	if card_data:
		return tr(card_data.display_name)
	return card_id.capitalize().replace("_", " ")

## Helper: Convert mood to text
func _mood_to_text(mood: float) -> String:
	if mood >= 0.7:
		return "Exalted"
	elif mood >= 0.3:
		return "Hopeful"
	elif mood >= -0.3:
		return "Neutral"
	elif mood >= -0.7:
		return "Troubled"
	else:
		return "Despairing"

## Helper: Get entities with most synergies
func _get_notable_entities() -> Array:
	var entities: Array = []
	for card_id in chronicle.entity_states:
		var entity: EntityState = chronicle.entity_states[card_id]
		if entity.synergies_formed >= 2:
			entities.append(card_id)
	
	# Sort by synergy count
	entities.sort_custom(func(a, b):
		var ea: EntityState = chronicle.entity_states[a]
		var eb: EntityState = chronicle.entity_states[b]
		return ea.synergies_formed > eb.synergies_formed
	)
	
	return entities.slice(0, 5) # Top 5

## Helper: Get key memories (high DP, near death, victories)
func _get_key_memories() -> Array[MemoryEntry]:
	var key: Array[MemoryEntry] = []
	
	for memory in chronicle.memories:
		match memory.type:
			MemoryEntry.MemoryType.HIGH_DP_MOMENT, \
			MemoryEntry.MemoryType.NEAR_DEATH, \
			MemoryEntry.MemoryType.CHAPTER_VICTORY:
				key.append(memory)
	
	return key.slice(0, 5) # Top 5

## Helper: Check for story arc triggers
func _check_arc_triggers(card1_id: String, card2_id: String, result: Dictionary, thread_type: int) -> void:
	var _dp: int = result.get("dp_bonus", 0) # Prefixed - used for arc triggers
	
	# Get card data for tag analysis
	var card1_data = DataManager.get_card_data(card1_id)
	var card2_data = DataManager.get_card_data(card2_id)
	
	if not card1_data or not card2_data:
		return
	
	# Check for Heroic Journey arc
	if _has_tag(card1_data, "heroic") or _has_tag(card2_data, "heroic"):
		var hero_id := card1_id if _has_tag(card1_data, "heroic") else card2_id
		var item_id := card2_id if hero_id == card1_id else card1_id
		
		# Check if arc already exists
		var existing_arc := chronicle.find_arc_for_card(hero_id)
		if not existing_arc:
			# Start new heroic journey
			var arc := StoryArc.new()
			arc.arc_type = StoryArc.ArcType.HEROIC_JOURNEY
			arc.protagonist_id = hero_id
			arc.supporting_ids.append(item_id)
			arc.start_turn = GameManager.turn_count
			arc.start_chapter = 0
			chronicle.active_arcs.append(arc)
			arc_started.emit(arc)
			print("ChronicleManager: Started HEROIC_JOURNEY arc for %s" % hero_id)
		else:
			# Progress existing arc
			var phase_changed := existing_arc.advance(0.15)
			if not existing_arc.supporting_ids.has(item_id):
				existing_arc.supporting_ids.append(item_id)
			if phase_changed:
				arc_progressed.emit(existing_arc, existing_arc.phase)
	
	# Check for Romance arc
	if _has_tag(card1_data, "romance") and _has_tag(card2_data, "romance"):
		var existing_arc := _find_romance_arc(card1_id, card2_id)
		if not existing_arc:
			var arc := StoryArc.new()
			arc.arc_type = StoryArc.ArcType.ROMANCE
			arc.protagonist_id = card1_id
			arc.antagonist_id = card2_id # In romance, "antagonist" is love interest
			arc.start_turn = GameManager.turn_count
			arc.start_chapter = 0
			chronicle.active_arcs.append(arc)
			arc_started.emit(arc)
			print("ChronicleManager: Started ROMANCE arc for %s and %s" % [card1_id, card2_id])
		else:
			var phase_changed := existing_arc.advance(0.2)
			if phase_changed:
				arc_progressed.emit(existing_arc, existing_arc.phase)
	
	# Check for Corruption arc (violence thread + cursed tag)
	if thread_type == 1 and (_has_tag(card1_data, "cursed") or _has_tag(card2_data, "cursed")):
		var cursed_id := card1_id if _has_tag(card1_data, "cursed") else card2_id
		var victim_id := card2_id if cursed_id == card1_id else card1_id
		
		var existing := chronicle.find_arc_for_card(victim_id)
		if existing and existing.arc_type == StoryArc.ArcType.HEROIC_JOURNEY:
			# Convert to corruption arc
			existing.arc_type = StoryArc.ArcType.CORRUPTION
			existing.antagonist_id = cursed_id
			print("ChronicleManager: HEROIC_JOURNEY converted to CORRUPTION for %s" % victim_id)
	
	# Check for Tragedy arc (tragedy tag + high chaos)
	if _has_tag(card1_data, "tragedy") or _has_tag(card2_data, "tragedy"):
		var chaos: int = result.get("chaos_change", 0)
		if chaos >= 20:
			var tragic_id := card1_id if _has_tag(card1_data, "tragedy") else card2_id
			var existing := chronicle.find_arc_for_card(tragic_id)
			if not existing:
				var arc := StoryArc.new()
				arc.arc_type = StoryArc.ArcType.TRAGEDY
				arc.protagonist_id = tragic_id
				arc.start_turn = GameManager.turn_count
				arc.start_chapter = 0
				chronicle.active_arcs.append(arc)
				arc_started.emit(arc)
				print("ChronicleManager: Started TRAGEDY arc for %s" % tragic_id)
	
	# Check for Revenge arc (violence + failed synergy history)
	if thread_type == 1: # Violence thread
		var rel := chronicle.get_or_create_relationship(card1_id, card2_id)
		if rel.failed_synergies >= 2 and rel.affinity <= -0.3:
			var existing := chronicle.find_arc_for_card(card1_id)
			if not existing or existing.arc_type != StoryArc.ArcType.REVENGE:
				var arc := StoryArc.new()
				arc.arc_type = StoryArc.ArcType.REVENGE
				arc.protagonist_id = card1_id
				arc.antagonist_id = card2_id
				arc.start_turn = GameManager.turn_count
				arc.start_chapter = 0
				chronicle.active_arcs.append(arc)
				arc_started.emit(arc)
				print("ChronicleManager: Started REVENGE arc for %s against %s" % [card1_id, card2_id])
	
	# Check for Redemption arc (hope tag + existing corruption arc)
	if _has_tag(card1_data, "hope") or _has_tag(card2_data, "hope"):
		var hope_id := card1_id if _has_tag(card1_data, "hope") else card2_id
		var existing := chronicle.find_arc_for_card(hope_id)
		if existing and existing.arc_type == StoryArc.ArcType.CORRUPTION:
			# Convert corruption to redemption!
			existing.arc_type = StoryArc.ArcType.REDEMPTION
			print("ChronicleManager: CORRUPTION converted to REDEMPTION for %s!" % hope_id)
		elif not existing and _has_tag(card1_data, "redemption") or _has_tag(card2_data, "redemption"):
			var redeemed_id := card1_id if _has_tag(card1_data, "redemption") else card2_id
			var arc := StoryArc.new()
			arc.arc_type = StoryArc.ArcType.REDEMPTION
			arc.protagonist_id = redeemed_id
			arc.start_turn = GameManager.turn_count
			arc.start_chapter = 0
			chronicle.active_arcs.append(arc)
			arc_started.emit(arc)
			print("ChronicleManager: Started REDEMPTION arc for %s" % redeemed_id)
	
	# Check for Betrayal arc (betrayal tag + existing bond)
	if _has_tag(card1_data, "betrayal") or _has_tag(card2_data, "betrayal"):
		var betrayer_id := card1_id if _has_tag(card1_data, "betrayal") else card2_id
		var victim_id := card2_id if betrayer_id == card1_id else card1_id
		var rel := chronicle.get_or_create_relationship(card1_id, card2_id)
		if rel.affinity >= 0.3: # Had a positive relationship
			var arc := StoryArc.new()
			arc.arc_type = StoryArc.ArcType.BETRAYAL
			arc.protagonist_id = victim_id # Victim is protagonist
			arc.antagonist_id = betrayer_id
			arc.start_turn = GameManager.turn_count
			arc.start_chapter = 0
			chronicle.active_arcs.append(arc)
			arc_started.emit(arc)
			# Damage the relationship
			rel.affinity = -0.5
			print("ChronicleManager: Started BETRAYAL arc - %s betrayed by %s" % [victim_id, betrayer_id])
	
	# Check for Sacrifice arc (sacrifice tag + near death situation)
	if _has_tag(card1_data, "sacrifice") or _has_tag(card2_data, "sacrifice"):
		if GameManager.current_chaos >= GameManager.current_chapter.max_chaos - 15:
			var sacrificer_id := card1_id if _has_tag(card1_data, "sacrifice") else card2_id
			var saved_id := card2_id if sacrificer_id == card1_id else card1_id
			var existing := chronicle.find_arc_for_card(sacrificer_id)
			if not existing:
				var arc := StoryArc.new()
				arc.arc_type = StoryArc.ArcType.SACRIFICE
				arc.protagonist_id = sacrificer_id
				arc.supporting_ids.append(saved_id)
				arc.start_turn = GameManager.turn_count
				arc.start_chapter = 0
				chronicle.active_arcs.append(arc)
				arc_started.emit(arc)
				print("ChronicleManager: Started SACRIFICE arc for %s" % sacrificer_id)
	
	# Check for Reunion arc (family/reunion tags + prior separation)
	if (_has_tag(card1_data, "family") and _has_tag(card2_data, "family")) or \
	   (_has_tag(card1_data, "reunion") or _has_tag(card2_data, "reunion")):
		var rel := chronicle.get_or_create_relationship(card1_id, card2_id)
		# First meeting of family members
		if rel.interaction_count == 0:
			var arc := StoryArc.new()
			arc.arc_type = StoryArc.ArcType.REUNION
			arc.protagonist_id = card1_id
			arc.antagonist_id = card2_id # Second family member
			arc.start_turn = GameManager.turn_count
			arc.start_chapter = 0
			chronicle.active_arcs.append(arc)
			arc_started.emit(arc)
			print("ChronicleManager: Started REUNION arc for %s and %s" % [card1_id, card2_id])

## Helper: Check if card has a specific tag
func _has_tag(card_data: CardData, tag: String) -> bool:
	return card_data.tags.has(tag)

## Helper: Find a romance arc between two specific cards
func _find_romance_arc(card1_id: String, card2_id: String) -> StoryArc:
	for arc in chronicle.active_arcs:
		if arc.arc_type == StoryArc.ArcType.ROMANCE:
			if (arc.protagonist_id == card1_id and arc.antagonist_id == card2_id) or \
			   (arc.protagonist_id == card2_id and arc.antagonist_id == card1_id):
				return arc
	return null
