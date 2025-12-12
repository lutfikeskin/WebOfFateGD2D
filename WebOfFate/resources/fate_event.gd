class_name FateEvent extends Resource

## Dynamic events that occur during gameplay to change board state.
## Triggered every 3-5 turns to add strategic variety.

enum EventType {
	SOLAR_ECLIPSE, ## Gold threads become Red for 2 turns
	LUNAR_BLESSING, ## Next synergy: no Chaos
	PROPHECY, ## See and reorder next 3 cards
	FATES_CROSSROAD, ## Choose: +20 DP or -20 Chaos
	THREAD_STORM, ## All threads randomize colors
	CHAOS_SURGE, ## +15 Chaos but +30 DP potential
	HARMONY_WAVE, ## All current cards get +5 DP
	DESTINY_MIRROR, ## Duplicate next synergy effect
	VOID_TOUCH, ## One random slot becomes inactive for 2 turns
	ANCIENT_BLESSING ## Legendary card appears in next draw
}

@export var event_type: EventType = EventType.LUNAR_BLESSING
@export var title: String = ""
@export var description: String = ""
@export var duration_turns: int = 0 # 0 = instant effect

## Get event data by type
static func create_event(type: EventType) -> FateEvent:
	var event := FateEvent.new()
	event.event_type = type
	
	match type:
		EventType.SOLAR_ECLIPSE:
			event.title = "Solar Eclipse"
			event.description = "Darkness falls! All Gold threads become Red for 2 turns."
			event.duration_turns = 2
		
		EventType.LUNAR_BLESSING:
			event.title = "Lunar Blessing"
			event.description = "The moon smiles upon you. Your next synergy produces no Chaos."
			event.duration_turns = 0
		
		EventType.PROPHECY:
			event.title = "Prophecy"
			event.description = "The fates reveal... See your next 3 cards and reorder them."
			event.duration_turns = 0
		
		EventType.FATES_CROSSROAD:
			event.title = "Fate's Crossroad"
			event.description = "Choose your path: Gain +20 DP immediately, or reduce Chaos by 20."
			event.duration_turns = 0
		
		EventType.THREAD_STORM:
			event.title = "Thread Storm"
			event.description = "A storm of fate! All thread colors shift randomly."
			event.duration_turns = 0
		
		EventType.CHAOS_SURGE:
			event.title = "Chaos Surge"
			event.description = "Chaos builds! +15 Chaos, but all synergies give +50% DP this turn."
			event.duration_turns = 1
		
		EventType.HARMONY_WAVE:
			event.title = "Harmony Wave"
			event.description = "Peace flows through the loom. All cards on board gain +5 effective DP."
			event.duration_turns = 1
		
		EventType.DESTINY_MIRROR:
			event.title = "Destiny Mirror"
			event.description = "Your next synergy's effect will be doubled!"
			event.duration_turns = 0
		
		EventType.VOID_TOUCH:
			event.title = "Void Touch"
			event.description = "The void reaches out. One random slot becomes inactive for 2 turns."
			event.duration_turns = 2
		
		EventType.ANCIENT_BLESSING:
			event.title = "Ancient Blessing"
			event.description = "The ancients smile upon you. A Legendary card will appear in your next draw."
			event.duration_turns = 0
	
	return event

## Get color for UI display
func get_event_color() -> Color:
	match event_type:
		EventType.SOLAR_ECLIPSE, EventType.VOID_TOUCH:
			return Color(0.6, 0.2, 0.4) # Dark purple (negative)
		EventType.CHAOS_SURGE:
			return Color(0.8, 0.3, 0.2) # Red-orange (risky)
		EventType.LUNAR_BLESSING, EventType.HARMONY_WAVE, EventType.ANCIENT_BLESSING:
			return Color(0.3, 0.7, 0.9) # Cyan (positive)
		EventType.PROPHECY, EventType.DESTINY_MIRROR:
			return Color(0.8, 0.6, 0.9) # Light purple (mystic)
		EventType.FATES_CROSSROAD:
			return Color(0.9, 0.8, 0.3) # Gold (choice)
		_:
			return Color.WHITE
