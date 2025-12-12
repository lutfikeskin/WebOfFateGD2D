class_name CardData extends CardResource

enum Category {
	CHARACTER,
	ITEM,
	EVENT,
	LOCATION,
	DISASTER
}

enum Rarity {
	COMMON, ## 60% drop rate, 1.0x DP
	RARE, ## 25% drop rate, 1.3x DP
	EPIC, ## 12% drop rate, 1.6x DP
	LEGENDARY ## 3% drop rate, 2.0x DP
}

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var category: Category
@export var rarity: Rarity = Rarity.COMMON
@export var tags: Array[String] = []
@export var base_dp: int = 0
@export var base_chaos: int = 0
@export var texture_path: String # Optional if using top_texture

# Legacy support for Balatro UI until refactored
@export var top_texture: Texture2D
@export var card_suit: int = 0 # Placeholder
@export var value: int = 0 # Placeholder

## Get DP multiplier based on rarity
func get_rarity_multiplier() -> float:
	match rarity:
		Rarity.COMMON: return 1.0
		Rarity.RARE: return 1.3
		Rarity.EPIC: return 1.6
		Rarity.LEGENDARY: return 2.0
	return 1.0

## Get effective DP (base * rarity multiplier)
func get_effective_dp() -> int:
	return int(base_dp * get_rarity_multiplier())

## Get rarity color for UI
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.RARE: return Color(0.3, 0.5, 1.0) # Blue
		Rarity.EPIC: return Color(0.6, 0.2, 0.8) # Purple
		Rarity.LEGENDARY: return Color(1.0, 0.8, 0.2) # Gold
	return Color.WHITE

func _init(p_id: String = "", p_name: String = "", p_cat: Category = Category.CHARACTER, p_dp: int = 0, p_chaos: int = 0) -> void:
	id = p_id
	display_name = p_name
	category = p_cat
	base_dp = p_dp
	base_chaos = p_chaos
