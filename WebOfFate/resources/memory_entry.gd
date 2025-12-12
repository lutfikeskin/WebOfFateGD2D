class_name MemoryEntry extends Resource

## Records a single narrative-significant event.
## Part of the Chronicle System for emergent narratives.

enum MemoryType {
	SYNERGY_FORMED, ## Two cards formed a synergy
	SYNERGY_FAILED, ## Cards sat together without synergizing
	HIGH_DP_MOMENT, ## DP gained > 50 in single action
	CHAOS_SPIKE, ## Chaos increased > 20 in single action
	SACRIFICE, ## Card removed for strategic benefit
	NEAR_DEATH, ## Chaos came within 10 of max
	CHAPTER_VICTORY, ## Chapter completed successfully
	RUN_ENDED ## Run ended (victory or defeat)
}

## Type of memory event
@export var type: MemoryType = MemoryType.SYNERGY_FORMED
## Turn number when this occurred
@export var turn: int = 0
## Chapter number when this occurred
@export var chapter: int = 0
## Card IDs involved in this event
@export var involved_cards: Array[String] = []
## Thread type (0=white, 1=red, 2=gold, 3=purple)
@export var thread_type: int = 0
## DP result from this event
@export var dp_result: int = 0
## Chaos change from this event
@export var chaos_result: int = 0
## Generated narrative text for this event
@export var narrative_fragment: String = ""
## Unix timestamp for ordering
@export var timestamp: int = 0

## Create a synergy memory
static func create_synergy_memory(
	card1_id: String,
	card2_id: String,
	turn_num: int,
	chapter_num: int,
	thread: int,
	dp: int,
	chaos: int,
	narrative: String
) -> MemoryEntry:
	var memory := MemoryEntry.new()
	memory.type = MemoryType.SYNERGY_FORMED
	memory.involved_cards = [card1_id, card2_id]
	memory.turn = turn_num
	memory.chapter = chapter_num
	memory.thread_type = thread
	memory.dp_result = dp
	memory.chaos_result = chaos
	memory.narrative_fragment = narrative
	memory.timestamp = int(Time.get_unix_time_from_system())
	return memory

## Create a high DP moment memory
static func create_high_dp_memory(
	cards: Array[String],
	turn_num: int,
	chapter_num: int,
	dp: int
) -> MemoryEntry:
	var memory := MemoryEntry.new()
	memory.type = MemoryType.HIGH_DP_MOMENT
	memory.involved_cards = cards
	memory.turn = turn_num
	memory.chapter = chapter_num
	memory.dp_result = dp
	memory.timestamp = int(Time.get_unix_time_from_system())
	return memory

## Create a near-death memory
static func create_near_death_memory(
	turn_num: int,
	chapter_num: int,
	current_chaos: int,
	max_chaos: int
) -> MemoryEntry:
	var memory := MemoryEntry.new()
	memory.type = MemoryType.NEAR_DEATH
	memory.turn = turn_num
	memory.chapter = chapter_num
	memory.chaos_result = current_chaos
	memory.narrative_fragment = "Chaos reached %d of %d - doom nearly claimed all." % [current_chaos, max_chaos]
	memory.timestamp = int(Time.get_unix_time_from_system())
	return memory

## Get a human-readable type name
func get_type_name() -> String:
	match type:
		MemoryType.SYNERGY_FORMED: return "Synergy"
		MemoryType.SYNERGY_FAILED: return "Missed Connection"
		MemoryType.HIGH_DP_MOMENT: return "Legendary Moment"
		MemoryType.CHAOS_SPIKE: return "Chaos Surge"
		MemoryType.SACRIFICE: return "Sacrifice"
		MemoryType.NEAR_DEATH: return "Near Doom"
		MemoryType.CHAPTER_VICTORY: return "Victory"
		MemoryType.RUN_ENDED: return "Fate Sealed"
	return "Unknown"
