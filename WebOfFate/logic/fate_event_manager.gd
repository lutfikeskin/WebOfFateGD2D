extends Node

## Manages Fate Events - dynamic occurrences that alter gameplay.
## Events trigger every 3-5 turns to add variety and strategic challenges.

signal event_triggered(event: FateEvent)
signal event_expired(event: FateEvent)
signal choice_required(event: FateEvent, options: Array)

## Active events with remaining duration
var active_events: Array[FateEvent] = []

## Modifiers from active events
var next_synergy_no_chaos: bool = false
var next_synergy_doubled: bool = false
var dp_multiplier: float = 1.0
var guaranteed_legendary_next_draw: bool = false

## Track turns for event scheduling
var turns_since_last_event: int = 0
const MIN_TURNS_BETWEEN_EVENTS := 3
const MAX_TURNS_BETWEEN_EVENTS := 5

func _ready() -> void:
	# Connect to turn signals
	if TurnManager:
		TurnManager.turn_ended.connect(_on_turn_ended)

## Called each turn end to check for new events and update active ones
func _on_turn_ended() -> void:
	turns_since_last_event += 1
	
	# Update active event durations
	var expired: Array[FateEvent] = []
	for event in active_events:
		event.duration_turns -= 1
		if event.duration_turns <= 0:
			expired.append(event)
	
	# Remove expired events
	for event in expired:
		active_events.erase(event)
		_on_event_expired(event)
		event_expired.emit(event)
	
	# Check if new event should trigger
	if turns_since_last_event >= MIN_TURNS_BETWEEN_EVENTS:
		var chance := float(turns_since_last_event - MIN_TURNS_BETWEEN_EVENTS) / float(MAX_TURNS_BETWEEN_EVENTS - MIN_TURNS_BETWEEN_EVENTS)
		if randf() <= chance or turns_since_last_event >= MAX_TURNS_BETWEEN_EVENTS:
			trigger_random_event()
			turns_since_last_event = 0

## Trigger a random Fate Event
func trigger_random_event() -> void:
	var event_types := FateEvent.EventType.values()
	var random_type: int = event_types.pick_random()
	
	var event := FateEvent.create_event(random_type)
	_apply_event(event)
	
	if event.duration_turns > 0:
		active_events.append(event)
	
	event_triggered.emit(event)
	print("FateEventManager: Triggered '%s'" % event.title)

## Apply event effects
func _apply_event(event: FateEvent) -> void:
	match event.event_type:
		FateEvent.EventType.LUNAR_BLESSING:
			next_synergy_no_chaos = true
		
		FateEvent.EventType.CHAOS_SURGE:
			GameManager.current_chaos += 15
			dp_multiplier = 1.5
		
		FateEvent.EventType.HARMONY_WAVE:
			# Bonus DP will be applied in synergy calculation
			dp_multiplier = 1.2
		
		FateEvent.EventType.DESTINY_MIRROR:
			next_synergy_doubled = true
		
		FateEvent.EventType.ANCIENT_BLESSING:
			guaranteed_legendary_next_draw = true
		
		FateEvent.EventType.FATES_CROSSROAD:
			# This requires player choice - emit signal
			choice_required.emit(event, [
				{"label": "+20 DP", "action": "gain_dp"},
				{"label": "-20 Chaos", "action": "reduce_chaos"}
			])
		
		# TODO: Implement other event effects
		_:
			pass

## Handle event expiration
func _on_event_expired(event: FateEvent) -> void:
	match event.event_type:
		FateEvent.EventType.CHAOS_SURGE, FateEvent.EventType.HARMONY_WAVE:
			dp_multiplier = 1.0
		_:
			pass

## Called when player makes a choice for Fate's Crossroad
func apply_crossroad_choice(action: String) -> void:
	match action:
		"gain_dp":
			GameManager.total_dp += 20
			print("FateEventManager: Player chose +20 DP")
		"reduce_chaos":
			GameManager.current_chaos = maxi(0, GameManager.current_chaos - 20)
			print("FateEventManager: Player chose -20 Chaos")

## Get current DP multiplier from active events
func get_dp_multiplier() -> float:
	return dp_multiplier

## Check and consume next synergy modifiers
func consume_synergy_modifiers() -> Dictionary:
	var mods := {
		"no_chaos": next_synergy_no_chaos,
		"doubled": next_synergy_doubled
	}
	
	next_synergy_no_chaos = false
	next_synergy_doubled = false
	
	return mods

## Reset for new run
func reset() -> void:
	active_events.clear()
	next_synergy_no_chaos = false
	next_synergy_doubled = false
	dp_multiplier = 1.0
	guaranteed_legendary_next_draw = false
	turns_since_last_event = 0
