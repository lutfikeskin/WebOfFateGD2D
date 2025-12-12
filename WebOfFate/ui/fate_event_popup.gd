extends PanelContainer

## Fate Event Popup - Displays dynamic game events with visual flair

signal event_acknowledged()
signal choice_made(action: String)

@onready var title_label: Label = %EventTitle
@onready var description_label: RichTextLabel = %EventDescription
@onready var duration_label: Label = %DurationLabel
@onready var acknowledge_button: Button = %AcknowledgeButton
@onready var choices_container: HBoxContainer = %ChoicesContainer
@onready var event_icon: TextureRect = %EventIcon

var current_event: FateEvent
var pending_choices: Array = []

func _ready() -> void:
	acknowledge_button.pressed.connect(_on_acknowledge_pressed)
	visible = false
	
	# Connect to FateEventManager
	if FateEventManager:
		FateEventManager.event_triggered.connect(_on_event_triggered)
		FateEventManager.choice_required.connect(_on_choice_required)

## Display a fate event
func show_event(event: FateEvent) -> void:
	current_event = event
	
	# Set title with color
	title_label.text = event.title
	title_label.add_theme_color_override("font_color", event.get_event_color())
	
	# Set description
	description_label.clear()
	description_label.append_text("[center][i]%s[/i][/center]" % event.description)
	
	# Set duration
	if event.duration_turns > 0:
		duration_label.text = "%d turns remaining" % event.duration_turns
		duration_label.visible = true
	else:
		duration_label.text = "Instant Effect"
		duration_label.visible = true
	
	# Clear previous choice buttons
	for child in choices_container.get_children():
		child.queue_free()
	
	# Show appropriate controls
	if pending_choices.is_empty():
		acknowledge_button.visible = true
		choices_container.visible = false
	else:
		acknowledge_button.visible = false
		choices_container.visible = true
		_create_choice_buttons()
	
	# Animate in
	modulate.a = 0
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _create_choice_buttons() -> void:
	for choice in pending_choices:
		var btn = Button.new()
		btn.text = choice.label
		btn.custom_minimum_size = Vector2(150, 40)
		btn.pressed.connect(func(): _on_choice_button_pressed(choice.action))
		choices_container.add_child(btn)

func _on_choice_button_pressed(action: String) -> void:
	FateEventManager.apply_crossroad_choice(action)
	choice_made.emit(action)
	pending_choices.clear()
	_hide_popup()

func _on_acknowledge_pressed() -> void:
	event_acknowledged.emit()
	_hide_popup()

func _hide_popup() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	visible = false
	current_event = null

## Signal handlers
func _on_event_triggered(event: FateEvent) -> void:
	show_event(event)

func _on_choice_required(event: FateEvent, options: Array) -> void:
	pending_choices = options
	show_event(event)
