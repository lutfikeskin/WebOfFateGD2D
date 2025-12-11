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

