extends Node

# Autoload: GameManager
# Manages overall game state, progression, and level transitions.

signal state_changed(new_state: GameState)
signal chapter_loaded(chapter: ChapterData)
signal progress_updated(current_dp: int, target_dp: int, turns: int, max_turns: int)
signal level_complete(stats: Dictionary)
signal game_over(reason: String)

enum GameState {
	MENU,
	PLAYING,
	LEVEL_COMPLETE,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var current_chapter: ChapterData
var current_chapter_index: int = 0

# Run Stats
var total_dp: int = 0
var current_chaos: int = 0
var turn_count: int = 0

# Deck Persistence
var player_deck_cards: Array[CardData] = [] # The persistent deck list for the run

# Config - In a real game, this list would be loaded from a resource registry
var chapter_paths: Array[String] = [
	"res://WebOfFate/data/chapters/chapter_1_awakening.tres",
	"res://WebOfFate/data/chapters/chapter_2_tangled_paths.tres"
]

func _ready() -> void:
	pass

func start_new_run() -> void:
	reset_progress()
	
	# Load Chapter 1
	var chapter1 = load(chapter_paths[0])
	if chapter1:
		current_chapter_index = 0
		_initialize_deck_from_resource(chapter1.starting_deck)
		load_chapter(chapter1)
		
	# Setup initial save
	SaveManager.create_new_game()

func continue_run() -> void:
	if not SaveManager.current_save:
		start_new_run()
		return
		
	var save = SaveManager.current_save
	current_chapter_index = save.current_chapter_index
	
	# Restore Deck
	player_deck_cards.clear()
	for card_id in save.player_deck_ids:
		var card_data = DataManager.get_card_data(card_id)
		if card_data:
			player_deck_cards.append(card_data)
			
	# Load Current Chapter
	if current_chapter_index < chapter_paths.size():
		var chapter = load(chapter_paths[current_chapter_index])
		load_chapter(chapter)
	else:
		print("Game Complete! (No more chapters)")
		# Handle Game Completion state

func reset_progress() -> void:
	current_chapter_index = 0
	player_deck_cards.clear()
	total_dp = 0
	current_chaos = 0
	turn_count = 0

func load_chapter(chapter: ChapterData) -> void:
	current_chapter = chapter
	total_dp = 0
	current_chaos = 0
	turn_count = 0
	
	# If deck is empty (shouldn't happen in normal flow unless bug), init from chapter
	if player_deck_cards.is_empty() and chapter.starting_deck:
		_initialize_deck_from_resource(chapter.starting_deck)
	
	current_state = GameState.PLAYING
	state_changed.emit(GameState.PLAYING)
	chapter_loaded.emit(current_chapter)
	_emit_progress()
	
	AudioManager.play_music(AudioManager.Music.CHAPTER_THEME)

func _initialize_deck_from_resource(deck_res: CardDeck) -> void:
	player_deck_cards.clear()
	
	if not deck_res:
		print("GameManager: Cannot initialize deck, resource is null.")
		return
		
	# Check if 'cards' property exists and is valid (it should be if CardDeck resource is valid)
	if not "cards" in deck_res or deck_res.cards == null:
		print("GameManager: Deck resource has no 'cards' property.")
		return
		
	# CardDeck.cards is Array[CardResource], we need to cast/check
	for card_res in deck_res.cards:
		if card_res is CardData:
			player_deck_cards.append(card_res)
	print("GameManager: Deck initialized with %d cards." % player_deck_cards.size())

func add_card_to_deck(card_data: CardData) -> void:
	player_deck_cards.append(card_data)
	print("GameManager: Added %s to deck. Total: %d" % [card_data.display_name, player_deck_cards.size()])
	SaveManager.save_game()

func get_current_deck_resource() -> CardDeck:
	var deck = CardDeck.new()
	# CardDeck.cards expects Array[CardResource]
	var resource_array: Array[CardResource] = []
	for c in player_deck_cards:
		resource_array.append(c as CardResource)
	deck.cards = resource_array
	return deck

func update_progress(turn_dp: int, chaos_level: int) -> void:
	# Note: chaos_level passed from table is absolute
	if current_state != GameState.PLAYING:
		return
		
	# Only add the *delta* of DP (this method signature is tricky, let's assume table calls it with *totals* or *deltas*)
	# Looking at game_table.gd: GameManager.update_progress(outcome.dp + passive_results.dp, chaos)
	# It passes the *delta* DP for this turn, but *absolute* Chaos.
	
	# Wait, game_table.gd:222 passes `outcome.dp + passive_results.dp` which is turn delta.
	# But `destiny_points` in game_table accumulates.
	# Let's fix game_manager logic:
	
	# Assuming param 1 is DELTA DP, param 2 is ABSOLUTE CHAOS
	total_dp += turn_dp
	current_chaos = chaos_level 
	turn_count += 1
	
	_emit_progress()
	_check_win_loss()

func _check_win_loss() -> void:
	if not current_chapter: return
	
	# Check Win
	if total_dp >= current_chapter.target_dp:
		current_state = GameState.LEVEL_COMPLETE
		AudioManager.play_sfx(AudioManager.Sound.LEVEL_COMPLETE)
		level_complete.emit({
			"dp": total_dp,
			"turns": turn_count,
			"chaos": current_chaos
		})
		state_changed.emit(GameState.LEVEL_COMPLETE)
		return
		
	# Check Loss (Max Chaos checked by GameTable usually, but can be redundant here)
	if current_chaos >= current_chapter.max_chaos:
		trigger_game_over("Chaos limit reached!")
		return
		
	# Check Loss (Max Turns)
	if current_chapter.max_turns > 0 and turn_count >= current_chapter.max_turns:
		trigger_game_over("Run out of time (Turns)!")
		return

func trigger_game_over(reason: String) -> void:
	current_state = GameState.GAME_OVER
	game_over.emit(reason)
	state_changed.emit(GameState.GAME_OVER)
	SaveManager.create_new_game() # Reset save on death (Roguelike style)

func _emit_progress() -> void:
	if current_chapter:
		progress_updated.emit(total_dp, current_chapter.target_dp, turn_count, current_chapter.max_turns)

func next_level() -> void:
	current_chapter_index += 1
	if current_chapter_index < chapter_paths.size():
		var chapter = load(chapter_paths[current_chapter_index])
		load_chapter(chapter)
		SaveManager.save_game()
	else:
		print("Game Completed!")
		# TODO: Victory Screen

func restart_level() -> void:
	if current_chapter:
		load_chapter(current_chapter)
