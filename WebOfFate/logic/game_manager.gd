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

# Config
var chapters: Array[ChapterData] = []

func _ready() -> void:
	# Load chapters from data folder (placeholder logic, normally done by scanning or a progression resource)
	# For now we will manually add them when created
	pass

func load_chapter(chapter: ChapterData) -> void:
	current_chapter = chapter
	total_dp = 0
	current_chaos = 0
	turn_count = 0
	
	current_state = GameState.PLAYING
	state_changed.emit(GameState.PLAYING)
	chapter_loaded.emit(current_chapter)
	_emit_progress()

func update_progress(turn_dp: int, turn_chaos: int) -> void:
	if current_state != GameState.PLAYING:
		return
		
	total_dp += turn_dp
	current_chaos = turn_chaos # Chaos is usually absolute, managed by GameTable
	turn_count += 1
	
	_emit_progress()
	_check_win_loss()

func _check_win_loss() -> void:
	if not current_chapter: return
	
	# Check Win
	if total_dp >= current_chapter.target_dp:
		current_state = GameState.LEVEL_COMPLETE
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

func _emit_progress() -> void:
	if current_chapter:
		progress_updated.emit(total_dp, current_chapter.target_dp, turn_count, current_chapter.max_turns)

func next_level() -> void:
	# Logic to load next chapter
	# For prototype, just reload same or placeholder
	pass

func restart_level() -> void:
	if current_chapter:
		load_chapter(current_chapter)

