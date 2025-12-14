extends Node

# Autoload: SaveManager
# Handles saving and loading game state to disk.

signal save_loaded(save_data: SaveGame)

var current_save: SaveGame

func _ready() -> void:
	# Try load on startup
	load_game()

func load_game() -> bool:
	current_save = SaveGame.load_save()
	if current_save:
		# Restore Chronicle data if exists
		if current_save.chronicle:
			ChronicleManager.chronicle = current_save.chronicle
			
		# Restore Active Path
		if current_save.active_path_type >= 0:
			var paths = BidData.get_all_paths()
			if current_save.active_path_type < paths.size():
				GameManager.set_active_path(paths[current_save.active_path_type])
				
		print("SaveManager: Save loaded successfully.")
		return true
	else:
		print("SaveManager: No save found, creating new.")
		current_save = SaveGame.new()
		return false

func save_game() -> void:
	if not current_save:
		current_save = SaveGame.new()
	
	# Sync data from GameManagers
	# current_save.current_chapter_index removed (Chapter system deprecated)
	
	# Convert CardData objects to IDs for storage
	var deck_ids: Array[String] = []
	for card in GameManager.player_deck_cards:
		if card and card.id:
			deck_ids.append(card.id)
	current_save.player_deck_ids = deck_ids
	
	# Sync Chronicle data
	# Use duplicate(true) to ensure we save a snapshot and break references if needed
	if ChronicleManager.chronicle:
		current_save.chronicle = ChronicleManager.chronicle.duplicate(true)
		
	# Save Active Path
	if GameManager.active_path:
		current_save.active_path_type = GameManager.active_path.path_type
	else:
		current_save.active_path_type = -1
	
	# Save to disk
	current_save.write_save()
	print("SaveManager: Game saved.")

func create_new_game() -> void:
	SaveGame.delete_save()
	current_save = SaveGame.new()
	# Reset GameManager state
	GameManager.reset_progress()
	# Save immediately to establish file
	save_game()

func has_save_file() -> bool:
	return ResourceLoader.exists(SaveGame.SAVE_PATH)
