class_name StoryArc extends Resource

## Represents an emergent narrative arc.
## Part of the Chronicle System for emergent narratives.

enum ArcType {
	HEROIC_JOURNEY, ## Classic hero's rise
	CORRUPTION, ## Fall from grace
	REDEMPTION, ## Recovery from darkness
	REVENGE, ## Vendetta storyline
	ROMANCE, ## Love story
	TRAGEDY, ## Doomed from the start
	MYSTERY, ## Unfolding secrets
	BETRAYAL, ## Trust broken
	SACRIFICE, ## Noble self-sacrifice
	REUNION ## Long-lost reunited
}

enum ArcPhase {
	INTRO,
	RISING,
	CLIMAX,
	RESOLUTION
}

## Type of narrative arc
@export var arc_type: ArcType = ArcType.HEROIC_JOURNEY
## Current phase of the arc
@export var phase: ArcPhase = ArcPhase.INTRO
## Main character card ID
@export var protagonist_id: String = ""
## Opposing force card ID (optional)
@export var antagonist_id: String = ""
## Supporting character card IDs
@export var supporting_ids: Array[String] = []
## Progress from 0.0 to 1.0
@export_range(0.0, 1.0) var progress: float = 0.0
## Key memories that shaped this arc
@export var key_memories: Array[MemoryEntry] = []
## Whether this arc has concluded
@export var is_resolved: bool = false
## How the arc ended: "triumph", "tragedy", "abandoned"
@export var resolution_type: String = ""
## Turn when arc started
@export var start_turn: int = 0
## Chapter when arc started
@export var start_chapter: int = 0

## Arc trigger conditions: what starts each arc type
const ARC_TRIGGERS := {
	ArcType.HEROIC_JOURNEY: {
		"required_tags": ["heroic"],
		"item_synergy": true, # Hero + Item
		"min_dp": 30
	},
	ArcType.CORRUPTION: {
		"required_tags": ["cursed", "dark"],
		"chaos_threshold": 50
	},
	ArcType.REDEMPTION: {
		"required_tags": ["hope", "redemption"],
		"requires_corrupted": true # Must have Corruption arc first
	},
	ArcType.ROMANCE: {
		"required_tags": ["romance"],
		"min_synergies": 2
	},
	ArcType.TRAGEDY: {
		"required_tags": ["tragedy", "doomed"],
		"high_chaos": true
	},
	ArcType.REVENGE: {
		"required_tags": ["violence"],
		"failed_synergy_first": true
	},
	ArcType.BETRAYAL: {
		"required_tags": ["betrayal", "treachery"],
		"bond_required": true # Must have existing bond
	},
	ArcType.SACRIFICE: {
		"required_tags": ["sacrifice", "noble"],
		"near_death_required": true
	},
	ArcType.REUNION: {
		"required_tags": ["reunion", "family"],
		"separated_first": true
	},
	ArcType.MYSTERY: {
		"required_tags": ["mystic", "secret"],
		"min_synergies": 1
	}
}

## Get arc type name for display
func get_arc_name() -> String:
	match arc_type:
		ArcType.HEROIC_JOURNEY: return "The Hero's Journey"
		ArcType.CORRUPTION: return "Fall from Grace"
		ArcType.REDEMPTION: return "Path to Redemption"
		ArcType.REVENGE: return "Blood Vendetta"
		ArcType.ROMANCE: return "Threads of Love"
		ArcType.TRAGEDY: return "Doom's Embrace"
		ArcType.MYSTERY: return "Unraveling Secrets"
		ArcType.BETRAYAL: return "Broken Trust"
		ArcType.SACRIFICE: return "Noble Sacrifice"
		ArcType.REUNION: return "Threads Rejoined"
	return "Unknown Arc"

## Get phase name for display
func get_phase_name() -> String:
	match phase:
		ArcPhase.INTRO: return "Beginning"
		ArcPhase.RISING: return "Rising Action"
		ArcPhase.CLIMAX: return "Climax"
		ArcPhase.RESOLUTION: return "Resolution"
	return "Unknown"

## Advance progress and check for phase transitions
func advance(amount: float) -> bool:
	var old_phase := phase
	progress = clampf(progress + amount, 0.0, 1.0)
	
	# Determine phase based on progress
	if progress < 0.25:
		phase = ArcPhase.INTRO
	elif progress < 0.6:
		phase = ArcPhase.RISING
	elif progress < 0.9:
		phase = ArcPhase.CLIMAX
	else:
		phase = ArcPhase.RESOLUTION
	
	return phase != old_phase

## Resolve the arc
func resolve(is_triumph: bool) -> void:
	is_resolved = true
	progress = 1.0
	phase = ArcPhase.RESOLUTION
	resolution_type = "triumph" if is_triumph else "tragedy"

## Add a key memory to this arc
func add_key_memory(memory: MemoryEntry) -> void:
	key_memories.append(memory)
	# Keep max 5 key memories
	if key_memories.size() > 5:
		key_memories.remove_at(0)

## Check if a card is involved in this arc
func involves_card(card_id: String) -> bool:
	if card_id == protagonist_id or card_id == antagonist_id:
		return true
	return supporting_ids.has(card_id)
