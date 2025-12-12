class_name RelationshipData extends Resource

## Tracks the relationship between two specific cards.
## Part of the Chronicle System for emergent narratives.

## First card ID (alphabetically first for consistent keying)
@export var card_id_a: String = ""
## Second card ID
@export var card_id_b: String = ""
## Affinity ranges from -1.0 (enemies) to 1.0 (allies)
@export_range(-1.0, 1.0) var affinity: float = 0.0
## Total number of interactions
@export var interaction_count: int = 0
## Number of successful synergies together
@export var shared_synergies: int = 0
## Number of times they failed to synergize when adjacent
@export var failed_synergies: int = 0
## History of notable interactions
@export var history: Array[String] = []
## Most common thread type used between them (0-3)
@export var dominant_thread: int = 0
## Track thread type usage
@export var thread_counts: Array[int] = [0, 0, 0, 0]

## Create a sorted relationship key for consistent dictionary access
static func make_key(card1_id: String, card2_id: String) -> String:
	if card1_id < card2_id:
		return "%s_%s" % [card1_id, card2_id]
	else:
		return "%s_%s" % [card2_id, card1_id]

## Record an interaction between the cards
func record_interaction(synergy_formed: bool, thread_type: int, narrative: String = "") -> void:
	interaction_count += 1
	
	if synergy_formed:
		shared_synergies += 1
		affinity = clampf(affinity + 0.15, -1.0, 1.0)
	else:
		failed_synergies += 1
		affinity = clampf(affinity - 0.05, -1.0, 1.0)
	
	# Track thread type usage
	if thread_type >= 0 and thread_type < 4:
		thread_counts[thread_type] += 1
		_update_dominant_thread()
	
	# Add to history if notable
	if narrative != "":
		history.append(narrative)
		# Keep history manageable
		if history.size() > 10:
			history.remove_at(0)

## Update dominant thread based on usage counts
func _update_dominant_thread() -> void:
	var max_count := 0
	for i in range(4):
		if thread_counts[i] > max_count:
			max_count = thread_counts[i]
			dominant_thread = i

## Get relationship status as a string
func get_status() -> String:
	if affinity >= 0.7:
		return "legendary_bond"
	elif affinity >= 0.3:
		return "strong_bond"
	elif affinity >= 0.0:
		return "acquaintances"
	elif affinity >= -0.3:
		return "tension"
	elif affinity >= -0.7:
		return "rivalry"
	else:
		return "bitter_enemies"

## Get thread type name
func get_dominant_thread_name() -> String:
	match dominant_thread:
		0: return "White"
		1: return "Red"
		2: return "Gold"
		3: return "Purple"
	return "Unknown"

## Check if this is a notable relationship worth mentioning
func is_notable() -> bool:
	return interaction_count >= 3 or abs(affinity) >= 0.5
