class_name BidData extends Resource

## Represents a Path/Bid that modifies run parameters.
## Players choose one at run start for different challenge/reward experiences.

enum PathType {
	VALOR, ## High risk, high DP
	HARMONY, ## Low chaos, stable
	MYSTERY, ## Random events increased
	LEGEND ## Legendary focus
}

@export var path_type: PathType = PathType.VALOR
@export var path_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var starting_deck: CardDeck = null

@export_group("Modifiers")
## Multiplier for DP gains (1.0 = normal)
@export var dp_multiplier: float = 1.0
## Multiplier for Chaos gains (1.0 = normal)
@export var chaos_multiplier: float = 1.0
## Multiplier for Fate Event frequency (1.0 = normal)
@export var event_frequency_multiplier: float = 1.0
## Multiplier for Legendary card drop rate (1.0 = normal)
@export var legendary_rate_multiplier: float = 1.0

@export_group("Goal")
## Optional specific goal for bonus reward
@export var bonus_goal_type: String = "" # e.g., "synergy_count", "low_chaos"
@export var bonus_goal_value: int = 0
@export var bonus_reward_dp: int = 0

## Create default paths
static func create_path_of_valor() -> BidData:
	var path := BidData.new()
	path.path_type = PathType.VALOR
	path.path_name = "Path of Valor"
	path.description = "For those who seek glory! DP gains increased by 20%, but Chaos rises 15% faster."
	path.dp_multiplier = 1.2
	path.chaos_multiplier = 1.15
	path.bonus_goal_type = "high_dp"
	path.bonus_goal_value = 2000
	path.bonus_reward_dp = 500
	if ResourceLoader.exists("res://WebOfFate/data/decks/deck_valor.tres"):
		path.starting_deck = load("res://WebOfFate/data/decks/deck_valor.tres")
	return path

static func create_path_of_harmony() -> BidData:
	var path := BidData.new()
	path.path_type = PathType.HARMONY
	path.path_name = "Path of Harmony"
	path.description = "Balance and peace. Chaos reduced by 25%, but DP gains lowered by 10%."
	path.dp_multiplier = 0.9
	path.chaos_multiplier = 0.75
	path.bonus_goal_type = "low_chaos"
	path.bonus_goal_value = 30
	path.bonus_reward_dp = 300
	if ResourceLoader.exists("res://WebOfFate/data/decks/deck_harmony.tres"):
		path.starting_deck = load("res://WebOfFate/data/decks/deck_harmony.tres")
	return path

static func create_path_of_mystery() -> BidData:
	var path := BidData.new()
	path.path_type = PathType.MYSTERY
	path.path_name = "Path of Mystery"
	path.description = "Embrace the unknown! Fate Events occur twice as often. Expect chaos and opportunity."
	path.dp_multiplier = 1.0
	path.chaos_multiplier = 1.0
	path.event_frequency_multiplier = 2.0
	path.bonus_goal_type = "events_survived"
	path.bonus_goal_value = 10
	path.bonus_reward_dp = 400
	if ResourceLoader.exists("res://WebOfFate/data/decks/deck_mystery.tres"):
		path.starting_deck = load("res://WebOfFate/data/decks/deck_mystery.tres")
	return path

static func create_path_of_legend() -> BidData:
	var path := BidData.new()
	path.path_type = PathType.LEGEND
	path.path_name = "Path of Legend"
	path.description = "Seek the legendary! Legendary cards appear twice as often, but Chaos rises 30% faster."
	path.dp_multiplier = 1.0
	path.chaos_multiplier = 1.3
	path.legendary_rate_multiplier = 2.0
	path.bonus_goal_type = "legendary_synergies"
	path.bonus_goal_value = 5
	path.bonus_reward_dp = 600
	if ResourceLoader.exists("res://WebOfFate/data/decks/deck_legend.tres"):
		path.starting_deck = load("res://WebOfFate/data/decks/deck_legend.tres")
	return path

## Get all default paths
static func get_all_paths() -> Array[BidData]:
	return [
		create_path_of_valor(),
		create_path_of_harmony(),
		create_path_of_mystery(),
		create_path_of_legend()
	]

## Get color for UI
func get_path_color() -> Color:
	match path_type:
		PathType.VALOR: return Color(0.9, 0.3, 0.2) # Red
		PathType.HARMONY: return Color(0.3, 0.8, 0.5) # Green
		PathType.MYSTERY: return Color(0.6, 0.3, 0.8) # Purple
		PathType.LEGEND: return Color(1.0, 0.8, 0.2) # Gold
	return Color.WHITE
