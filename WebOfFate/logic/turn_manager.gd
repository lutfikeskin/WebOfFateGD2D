extends Node

# Autoload for managing the turn lifecycle and game phases.

signal turn_started(turn_number: int)
signal weaving_phase_started()
signal resolution_phase_started()
signal turn_ended()
signal game_over(reason: String)

enum Phase {
	IDLE,
	PLAYER_ACTION,
	WEAVING,
	RESOLUTION,
	GAME_OVER
}

var current_phase: Phase = Phase.IDLE
var is_busy: bool = false

func start_game() -> void:
	# Initial setup if needed
	start_turn()

func start_turn() -> void:
	current_phase = Phase.PLAYER_ACTION
	turn_started.emit(GameManager.turn_count) # Changed from current_turn to turn_count
	print("TurnManager: Turn Started")

func request_weave() -> void:
	if current_phase != Phase.PLAYER_ACTION:
		return
	
	is_busy = true
	current_phase = Phase.WEAVING
	weaving_phase_started.emit()
	print("TurnManager: Weaving Phase Started")
	
	# The actual weaving logic happens in GameTable (listening to this signal)
	# After weaving is done, GameTable should call complete_weaving()

func complete_weaving() -> void:
	if current_phase != Phase.WEAVING:
		return
	
	current_phase = Phase.RESOLUTION
	resolution_phase_started.emit()
	print("TurnManager: Resolution Phase Started")
	
	# After resolution logic (animations, cleanup), we end the turn
	# For now, we can do it immediately or wait for a callback
	call_deferred("end_turn")

func end_turn() -> void:
	if current_phase == Phase.GAME_OVER:
		return
		
	current_phase = Phase.IDLE
	is_busy = false
	turn_ended.emit()
	print("TurnManager: Turn Ended")
	
	# Start next turn automatically or wait for input?
	# Usually start next turn immediately in this genre
	start_turn()

func trigger_game_over(reason: String) -> void:
	current_phase = Phase.GAME_OVER
	game_over.emit(reason)
	print("TurnManager: Game Over - " + reason)
