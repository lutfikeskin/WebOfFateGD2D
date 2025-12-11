extends Control

@onready var continue_button: Button = %ContinueButton
@onready var play_button: Button = %PlayButton
@onready var how_to_play_button: Button = %HowToPlayButton
@onready var quit_button: Button = %QuitButton
@onready var lang_option_button: OptionButton = %LangOptionButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	play_button.pressed.connect(_on_play_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Setup Language Option
	lang_option_button.item_selected.connect(_on_language_selected)
	
	# Set current selection based on current locale
	var current_locale = TranslationServer.get_locale()
	if current_locale.begins_with("tr"):
		lang_option_button.selected = 1 # Türkçe
	else:
		lang_option_button.selected = 0 # English
	
	# Check for save game
	if SaveManager.has_save_file():
		continue_button.visible = true
		play_button.text = "MENU_NEW_GAME" # Change text to indicate reset
	else:
		continue_button.visible = false
		play_button.text = "MENU_PLAY"

func _on_continue_pressed() -> void:
	GameManager.continue_run()
	get_tree().change_scene_to_file("res://WebOfFate/WebOfFate.tscn")

func _on_play_pressed() -> void:
	GameManager.start_new_run()
	get_tree().change_scene_to_file("res://WebOfFate/WebOfFate.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://WebOfFate/tutorial.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_language_selected(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("tr")
