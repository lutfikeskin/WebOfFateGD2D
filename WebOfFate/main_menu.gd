extends Control

@onready var play_button: Button = %PlayButton
@onready var how_to_play_button: Button = %HowToPlayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	# Load main game scene
	get_tree().change_scene_to_file("res://WebOfFate/WebOfFate.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://WebOfFate/tutorial.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
