extends CanvasLayer
class_name WebOfFateController


@onready var card_deck_manager: CardDeckManager = $CardDeckManager
@onready var player_hand: PlayerHand = $PlayerHand
@onready var game_table: GameTable = $GameTable
@onready var screen_shaker: ScreenShaker = $Camera2D

@onready var weave_fate_button: Button = %WeaveFateButton
@onready var story_label: RichTextLabel = %StoryLabel
@onready var destiny_points_label: Label = $ResourcePanel/DestinyPointsLabel
@onready var chaos_label: Label = $ResourcePanel/ChaosLabel
@onready var chaos_progress_bar: ProgressBar = $ResourcePanel/ChaosProgressBar

# Game Info UI
@onready var chapter_label: Label = %ChapterLabel
@onready var progress_label: Label = %ProgressLabel
@onready var turn_label: Label = %TurnLabel

# Panels
@onready var level_complete_panel: PanelContainer = $LevelCompletePanel
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var chapter_start_panel: PanelContainer = $ChapterStartPanel
@onready var card_reward_panel: PanelContainer = $CardRewardPanel # New reference
@onready var chronicle_panel: PanelContainer = $ChroniclePanel # Chronicle System UI
@onready var next_level_button: Button = %NextLevelButton
@onready var restart_button: Button = %RestartButton
@onready var start_chapter_button: Button = %StartButton
@onready var start_title_label: Label = %TitleLabel
@onready var start_desc_label: RichTextLabel = %DescriptionLabel

var sort_by_suit: bool = false
var hand_size: int

func _init() -> void:
	CG.def_front_layout = "web_of_fate_card_layout"

func _ready() -> void:
	weave_fate_button.pressed.connect(_on_weave_fate_pressed)
	next_level_button.pressed.connect(_on_next_level_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	start_chapter_button.pressed.connect(_on_start_chapter_pressed)
	
	card_reward_panel.card_selected.connect(_on_reward_card_selected)
	card_reward_panel.skipped.connect(_on_reward_skipped)
	
	# Connect Chronicle Panel signals
	chronicle_panel.dismissed.connect(_on_chronicle_dismissed)
	
	# Connect game table signals
	game_table.resources_updated.connect(_on_resources_updated)
	game_table.story_updated.connect(_on_story_updated)
	game_table.card_discarded.connect(_on_card_discarded)
	# game_table.game_over.connect(...) # Deprecated, handled by TurnManager
	
	# Connect GameManager signals
	GameManager.progress_updated.connect(_on_progress_updated)
	GameManager.level_complete.connect(_on_level_complete)
	GameManager.chapter_loaded.connect(_on_chapter_loaded)
	# TurnManager now handles Game Over triggering and events
	TurnManager.game_over.connect(_on_tm_game_over)
	TurnManager.turn_ended.connect(_on_turn_ended)
	
	CG.def_front_layout = "web_of_fate_card_layout"

	hand_size = player_hand.max_hand_size
	
	card_deck_manager.setup()
	
	# If launched directly, load chapter 1 manually
	if not GameManager.current_chapter:
		var chapter1 = load("res://WebOfFate/data/chapters/chapter_1_awakening.tres")
		if chapter1:
			GameManager.load_chapter(chapter1)
	else:
		_on_chapter_loaded(GameManager.current_chapter)
	
	deal()
	
	# Initialize UI
	_update_resource_ui()

func _on_chapter_loaded(chapter: ChapterData) -> void:
	# Show start popup
	start_title_label.text = chapter.chapter_name
	start_desc_label.text = chapter.narrative_intro
	chapter_start_panel.visible = true
	weave_fate_button.disabled = true

func _on_start_chapter_pressed() -> void:
	chapter_start_panel.visible = false
	weave_fate_button.disabled = false
	# Call TurnManager instance via autoload name
	TurnManager.start_game()

func _on_progress_updated(current_dp: int, target_dp: int, turns: int, max_turns: int) -> void:
	if chapter_label:
		chapter_label.text = GameManager.current_chapter.chapter_name
	if progress_label:
		progress_label.text = tr("GAME_PROGRESS_LABEL") + ": %d / %d DP" % [current_dp, target_dp]
	if turn_label:
		turn_label.text = tr("GAME_TURN_LABEL") + ": %d / %d" % [turns, max_turns]

func _on_level_complete(_stats: Dictionary) -> void:
	print("Level Complete!")
	story_label.append_text("\n[color=green]GAME_LEVEL_COMPLETE[/color]")
	weave_fate_button.disabled = true
	# Show Chronicle first, then level complete panel
	chronicle_panel.show_chronicle(true)
	level_complete_panel.visible = true

func _on_tm_game_over(reason: String) -> void:
	print("Game Over (TM): ", reason)
	if screen_shaker: screen_shaker.add_trauma(0.8)
	# Record run end in Chronicle and show panel
	ChronicleManager.record_run_end(false, reason)
	chronicle_panel.show_chronicle(false)
	game_over_panel.visible = true
	weave_fate_button.disabled = true

func _on_next_level_pressed() -> void:
	level_complete_panel.visible = false
	
	# Start drafting phase before moving to next level
	card_reward_panel.show_rewards(3)

func _on_reward_card_selected(card_data: CardData) -> void:
	# Add selected card to persistent deck
	GameManager.add_card_to_deck(card_data)
	print("Drafted card: ", card_data.display_name)
	_proceed_to_next_level()

func _on_reward_skipped() -> void:
	print("Draft skipped.")
	_proceed_to_next_level()

func _on_chronicle_dismissed() -> void:
	# Chronicle panel was dismissed, nothing else to do
	pass

func _proceed_to_next_level() -> void:
	GameManager.next_level()
	# TODO: Implement actual loading of next chapter resource
	GameManager.restart_level()
	_reset_game_state()

func _on_restart_pressed() -> void:
	game_over_panel.visible = false
	GameManager.restart_level()
	_reset_game_state()

func _reset_game_state() -> void:
	weave_fate_button.disabled = false
	card_deck_manager.clear_deck() # Clear previous deck state
	
	# Clear hand properly
	for child in player_hand.get_children():
		if child is Card:
			player_hand.remove_card(child)
			child.queue_free()
	player_hand.clear_selected()
	
	# Clear table
	for slot in game_table.slots:
		if slot.has_card():
			var c = slot.remove_card()
			if c:
				c.queue_free()
			
	game_table.destiny_points = 0
	game_table.chaos = 0
	
	# Re-setup deck from initial resource (actually, use the Deck Manager's CURRENT state which is persistent now via GameManager)
	# But for now, we want to ensure deck is refreshed from GameManager's list
	var current_deck = GameManager.get_current_deck_resource()
	card_deck_manager.starting_deck = current_deck
	card_deck_manager.setup()
	
	deal()
	_update_resource_ui()
	# Call TurnManager instance via autoload name
	TurnManager.start_game()

func _on_weave_fate_pressed() -> void:
	# Call TurnManager instance via autoload name
	if TurnManager.is_busy: return
	
	# Disable button, Request Turn Manager to proceed
	weave_fate_button.disabled = true
	TurnManager.request_weave()

# Connected to TurnManager.turn_ended
func _on_turn_ended() -> void:
	# Turn ended (after resolution), now we prepare for next turn
	weave_fate_button.disabled = false
	deal()

func _on_resources_updated(_destiny_points: int, _chaos: int) -> void:
	_update_resource_ui()


func _on_story_updated(logs: Array) -> void:
	if logs.is_empty(): return
	story_label.append_text("\n")
	for entry in logs:
		story_label.append_text("- " + entry + "\n")
	
	# Scroll to bottom
	await get_tree().process_frame
	if story_label.get_parent() is ScrollContainer:
		var scroll = story_label.get_parent() as ScrollContainer
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_card_discarded(card: Card) -> void:
	card_deck_manager.add_card_to_discard_pile(card)

func _update_resource_ui() -> void:
	destiny_points_label.text = tr("GAME_DP_LABEL") + ": " + str(game_table.destiny_points)
	chaos_label.text = tr("GAME_CHAOS_LABEL") + ": " + str(game_table.chaos) + "/" + str(game_table.MAX_CHAOS)
	chaos_progress_bar.value = game_table.chaos

## Draw up to hand_size (5) cards, respecting current hand size
func deal():
	# Calculate how many cards we need to draw
	var current_hand_size = player_hand.get_card_count()
	var cards_needed = hand_size - current_hand_size
	
	# Only draw if we need cards
	if cards_needed <= 0:
		return
	
	# Draw cards up to hand_size
	var cards_drawn = 0
	
	# Try to draw from draw pile
	if card_deck_manager.get_draw_pile_size() > 0:
		var to_draw = min(cards_needed, card_deck_manager.get_draw_pile_size())
		var drawn = card_deck_manager.draw_cards(to_draw)
		player_hand.add_cards(drawn)
		cards_drawn += drawn.size()
		cards_needed -= cards_drawn
	
	# If we still need cards, reshuffle and draw more
	if cards_needed > 0:
		card_deck_manager.reshuffle_discard_and_shuffle()
		if card_deck_manager.get_draw_pile_size() > 0:
			var to_draw = min(cards_needed, card_deck_manager.get_draw_pile_size())
			var drawn = card_deck_manager.draw_cards(to_draw)
			player_hand.add_cards(drawn)
	
	# Sort hand
	player_hand.sort_by_value()
