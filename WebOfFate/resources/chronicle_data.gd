class_name ChronicleData extends Resource

## Master container for all narrative data in a run.
## Part of the Chronicle System for emergent narratives.

## All entity states indexed by card_id
@export var entity_states: Dictionary = {} # card_id -> EntityState
## All memories in chronological order
@export var memories: Array[MemoryEntry] = []
## All relationships indexed by sorted card pair key
@export var relationships: Dictionary = {} # "cardA_cardB" -> RelationshipData
## Active story arcs
@export var active_arcs: Array[StoryArc] = []
## Completed story arcs
@export var completed_arcs: Array[StoryArc] = []

@export_group("Run Statistics")
## Total synergies formed in this run
@export var total_synergies: int = 0
## Total turns elapsed
@export var total_turns: int = 0
## Highest single DP gain
@export var highest_single_dp: int = 0
## Highest chaos reached
@export var peak_chaos: int = 0
## Unix timestamp when run started
@export var run_start_time: int = 0

## Get or create an entity state for a card
func get_or_create_entity(card_id: String) -> EntityState:
	if entity_states.has(card_id):
		return entity_states[card_id]
	
	var entity := EntityState.new()
	entity.card_id = card_id
	entity.instance_id = EntityState.generate_instance_id(card_id)
	entity_states[card_id] = entity
	return entity

## Get or create a relationship between two cards
func get_or_create_relationship(card1_id: String, card2_id: String) -> RelationshipData:
	var key := RelationshipData.make_key(card1_id, card2_id)
	
	if relationships.has(key):
		return relationships[key]
	
	var rel := RelationshipData.new()
	# Ensure consistent ordering
	if card1_id < card2_id:
		rel.card_id_a = card1_id
		rel.card_id_b = card2_id
	else:
		rel.card_id_a = card2_id
		rel.card_id_b = card1_id
	relationships[key] = rel
	return rel

## Add a memory to the chronicle
func add_memory(memory: MemoryEntry) -> void:
	memories.append(memory)
	
	# Track high DP moments
	if memory.dp_result > highest_single_dp:
		highest_single_dp = memory.dp_result

## Get memories involving a specific card
func get_memories_for_card(card_id: String) -> Array[MemoryEntry]:
	var result: Array[MemoryEntry] = []
	for memory in memories:
		if memory.involved_cards.has(card_id):
			result.append(memory)
	return result

## Get the most recent N memories
func get_recent_memories(count: int) -> Array[MemoryEntry]:
	var result: Array[MemoryEntry] = []
	var start := maxi(0, memories.size() - count)
	for i in range(start, memories.size()):
		result.append(memories[i])
	return result

## Get all notable relationships
func get_notable_relationships() -> Array[RelationshipData]:
	var result: Array[RelationshipData] = []
	for key in relationships:
		var rel: RelationshipData = relationships[key]
		if rel.is_notable():
			result.append(rel)
	return result

## Find an active arc involving a specific card
func find_arc_for_card(card_id: String) -> StoryArc:
	for arc in active_arcs:
		if arc.involves_card(card_id):
			return arc
	return null

## Get statistics summary
func get_stats_summary() -> Dictionary:
	return {
		"total_synergies": total_synergies,
		"total_turns": total_turns,
		"peak_chaos": peak_chaos,
		"highest_dp": highest_single_dp,
		"entities_tracked": entity_states.size(),
		"relationships_formed": relationships.size(),
		"memories_recorded": memories.size(),
		"arcs_completed": completed_arcs.size()
	}
