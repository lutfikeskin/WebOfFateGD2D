class_name WebOfFateCardResource extends BalatroStyleResource

enum CardTag {
	NONE,
	VIOLENCE,
	MYSTIC,
	HOPE,
	TRAGEDY
}

@export var tags: Array[CardTag] = []
@export var base_dp: int = 0
@export var base_chaos: int = 0

