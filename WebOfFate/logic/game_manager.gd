extends Node

# Autoload: GameManager
# Manages overall game state, progression, and level transitions.

signal state_changed(new_state: GameState)
# signal chapter_loaded removed
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
# Run Configuration (formerly Chapters)
const TARGET_DP = 500
const MAX_CHAOS = 100
const MAX_TURNS = 10 # Soft limit

# Run Stats
var total_dp: int = 0
var current_chaos: int = 0
var turn_count: int = 0

# Deck Persistence
var player_deck_cards: Array[CardData] = []

# Active Path (Bid)
var active_path: BidData = null

func _ready() -> void:
	pass

## Get DP multiplier from active path
func get_dp_multiplier() -> float:
	if active_path:
		return active_path.dp_multiplier
	return 1.0

## Get Chaos multiplier from active path
func get_chaos_multiplier() -> float:
	if active_path:
		return active_path.chaos_multiplier
	return 1.0

## Set active path for the run
func set_active_path(path: BidData) -> void:
	active_path = path
	print("GameManager: Path selected - %s" % path.path_name)
	
	# Initialize Deck based on Path
	player_deck_cards.clear()
	if path.starting_deck:
		_initialize_deck_from_resource(path.starting_deck)
	else:
		# Fallback to Debug Deck
		var debug_deck = load("res://WebOfFate/cards/decks/debug_deck.tres")
		if debug_deck:
			_initialize_deck_from_resource(debug_deck)
	
	SaveManager.save_game()

func start_new_run() -> void:
	reset_progress()
	
	# Initialize Chronicle System for new run
	ChronicleManager.start_new_chronicle()
	
	current_state = GameState.PLAYING
	state_changed.emit(GameState.PLAYING)
	_emit_progress()
	
	AudioManager.play_music(AudioManager.Music.CHAPTER_THEME)
		
	# Setup initial save
	SaveManager.create_new_game()

func continue_run() -> void:
	if not SaveManager.current_save:
		start_new_run()
		return
		
	var save = SaveManager.current_save
	# Restore from save logic if needed (Deck restored below)
	
	# Restore Deck from Save
	player_deck_cards.clear()
	for card_id in save.player_deck_ids:
		var card_data = DataManager.get_card_data(card_id)
		if card_data:
			player_deck_cards.append(card_data)
			
	# If continuing mid-run, restore stats (assuming Save stores them, but currently SaveManager only syncs Deck/Chronicle/Path)
	# TODO: SaveManager needs to persist total_dp, current_chaos, turns too.
	# For now, just set state to PLAYING.
	
	current_state = GameState.PLAYING
	state_changed.emit(GameState.PLAYING)
	_emit_progress()
	
	# Resume music
	AudioManager.play_music(AudioManager.Music.CHAPTER_THEME)

func reset_progress() -> void:
	player_deck_cards.clear()
	total_dp = 0
	current_chaos = 0
	turn_count = 0
	active_path = null # Clear path on reset

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
	# Check Win
	if total_dp >= TARGET_DP:
		current_state = GameState.LEVEL_COMPLETE
		AudioManager.play_sfx(AudioManager.Sound.LEVEL_COMPLETE)
		level_complete.emit({
			"dp": total_dp,
			"turns": turn_count,
			"chaos": current_chaos
		})
		state_changed.emit(GameState.LEVEL_COMPLETE)
		return
		
	# Check Loss (Max Chaos)
	if current_chaos >= MAX_CHAOS:
		trigger_game_over("Chaos limit reached!")
		return
		
	# Check Loss (Max Turns)
	if MAX_TURNS > 0 and turn_count >= MAX_TURNS:
		trigger_game_over("Run out of time (Turns)!")
		return

func trigger_game_over(reason: String) -> void:
	current_state = GameState.GAME_OVER
	game_over.emit(reason)
	state_changed.emit(GameState.GAME_OVER)
	SaveManager.create_new_game() # Reset save on death (Roguelike style)

func _emit_progress() -> void:
	progress_updated.emit(total_dp, TARGET_DP, turn_count, MAX_TURNS)

func next_level() -> void:
	# Infinite run style or restart same goal? 
	# For now, just reset progress but keep deck
	total_dp = 0
	current_chaos = 0
	turn_count = 0
	# TODO: Maybe increase difficulty?
	
	current_state = GameState.PLAYING
	state_changed.emit(GameState.PLAYING)
	_emit_progress()
	
	SaveManager.save_game()

func restart_level() -> void:
	# Keep current path for restart
	var path_to_restart = active_path
	
	# Start new run (resets everything including active_path)
	start_new_run()
	
	# Restore path and deck
	if path_to_restart:
		set_active_path(path_to_restart)
