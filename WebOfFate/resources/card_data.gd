class_name CardData extends CardResource

enum Category {
	CHARACTER,
	ITEM,
	EVENT,
	LOCATION,
	DISASTER
}

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var category: Category
@export var tags: Array[String] = []
@export var base_dp: int = 0
@export var base_chaos: int = 0
@export var texture_path: String # Optional if using top_texture

# Legacy support for Balatro UI until refactored
@export var top_texture: Texture2D
@export var card_suit: int = 0 # Placeholder
@export var value: int = 0     # Placeholder

func _init(p_id: String = "", p_name: String = "", p_cat: Category = Category.CHARACTER, p_dp: int = 0, p_chaos: int = 0) -> void:
	id = p_id
	display_name = p_name
	category = p_cat
	base_dp = p_dp
	base_chaos = p_chaos
