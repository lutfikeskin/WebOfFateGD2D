class_name SynergyData
extends Resource

## Data container for specific card combinations (Synergies)

@export var id: String = ""
## The ID of the first card required for the synergy
@export var card_id_1: String = ""
## The ID of the second card required for the synergy
@export var card_id_2: String = ""

@export_group("Result")
## Destiny Points bonus granted by this synergy
@export var result_dp: int = 0
## Chaos change applied by this synergy (positive adds chaos, negative removes it)
@export var result_chaos: int = 0
## If true, both cards involved in the synergy will be removed from the board
@export var remove_cards: bool = true
## Narrative log message to display when this synergy triggers
@export var log_message: String = ""

@export_group("Anti-Synergy")
## If true, this is a negative synergy (cards conflict)
@export var is_negative: bool = false
## Tags that trigger this anti-synergy (alternative to specific card IDs)
@export var conflict_tags: Array[String] = []

## Check if this synergy is harmful
func is_harmful() -> bool:
	return is_negative or result_dp < 0 or result_chaos > 30

## Get display color based on type
func get_display_color() -> Color:
	if is_negative:
		return Color(0.8, 0.2, 0.2) # Red for anti-synergy
	elif result_chaos > 20:
		return Color(0.8, 0.5, 0.2) # Orange for high chaos
	else:
		return Color(0.2, 0.8, 0.3) # Green for positive
