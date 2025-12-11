extends Node

# Autoload: LoomManager
# Manages the logical state of the loom (slots, connections, threads).

signal card_placed(card: Card, slot_id: int)
signal card_removed(card: Card)

enum ThreadType {
	WHITE,  # Standard
	RED,    # Violence/Tragedy Bonus
	GOLD,   # Chaos Reduction
	PURPLE  # Shadow/Copy
}

var _slots: Dictionary = {} # slot_id -> GameSlot
var _connections: Array = [] # Array of Dictionaries {from: id, to: id, type: ThreadType}

func _ready() -> void:
	# Define default connections for 5 slots (Linear for now: 0-1-2-3-4)
	# In a real game this might be procedural or more complex
	define_connection(0, 1, ThreadType.WHITE)
	define_connection(1, 2, ThreadType.RED)
	define_connection(2, 3, ThreadType.WHITE)
	define_connection(3, 4, ThreadType.GOLD)

func register_slot(slot: GameSlot) -> void:
	_slots[slot.slot_id] = slot
	# Connect signals if needed, or GameTable handles it

func get_slot(slot_id: int) -> GameSlot:
	return _slots.get(slot_id)

func get_all_slots() -> Array:
	return _slots.values()

func define_connection(from_id: int, to_id: int, type: ThreadType) -> void:
	_connections.append({
		"from": from_id,
		"to": to_id,
		"type": type
	})

func get_connections_for_slot(slot_id: int) -> Array:
	var result = []
	for conn in _connections:
		if conn["from"] == slot_id:
			result.append({"target_slot": conn["to"], "type": conn["type"]})
		elif conn["to"] == slot_id:
			result.append({"target_slot": conn["from"], "type": conn["type"]})
	return result

func notify_card_placed(card: Card, slot_id: int) -> void:
	card_placed.emit(card, slot_id)

func notify_card_removed(card: Card) -> void:
	card_removed.emit(card)

