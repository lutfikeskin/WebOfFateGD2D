class_name SaveGame extends Resource

const SAVE_PATH = "user://savegame.tres"

@export var current_chapter_index: int = 0
@export var unlocked_cards: Array[String] = [] # List of Card IDs
@export var player_deck_ids: Array[String] = [] # IDs of cards in current deck
@export var high_score_dp: int = 0

func write_save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_save() -> SaveGame:
	if ResourceLoader.exists(SAVE_PATH):
		return load(SAVE_PATH)
	return null

static func delete_save() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

