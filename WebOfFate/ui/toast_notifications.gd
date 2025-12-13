extends Control

## Toast Notification System - Displays temporary overlapping messages

@onready var container: VBoxContainer = %NotificationContainer

const TOAST_DURATION: float = 4.0
const MAX_NOTIFICATIONS: int = 5

func _ready() -> void:
	# Connect to ChronicleManager signals for auto-notifications
	if ChronicleManager:
		ChronicleManager.arc_started.connect(_on_arc_started)
		ChronicleManager.arc_progressed.connect(_on_arc_progressed)
		ChronicleManager.arc_resolved.connect(_on_arc_resolved)
		ChronicleManager.entity_title_earned.connect(_on_title_earned)

## Show a custom notification
func show_notification(text: String, color: Color = Color.WHITE, icon: Texture2D = null) -> void:
	var toast = _create_toast(text, color, icon)
	container.add_child(toast)
	container.move_child(toast, 0) # Add to top
	
	# Limit count
	if container.get_child_count() > MAX_NOTIFICATIONS:
		var oldest = container.get_child(container.get_child_count() - 1)
		oldest.queue_free()
	
	# Audio cue
	if AudioManager and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx(AudioManager.Sound.HOVER, 1.5) # Reusing hover sound pitched up
	
	# Animate in
	toast.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(toast, "modulate:a", 1.0, 0.3)
	tween.tween_interval(TOAST_DURATION)
	tween.tween_property(toast, "modulate:a", 0.0, 0.5)
	tween.tween_callback(toast.queue_free)

func _create_toast(text: String, color: Color, icon: Texture2D) -> PanelContainer:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)
	
	if icon:
		var tex_rect = TextureRect.new()
		tex_rect.texture = icon
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(24, 24)
		hbox.add_child(tex_rect)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(label)
	
	return panel

# Signal Handlers

func _on_arc_started(arc: StoryArc) -> void:
	var msg = "Story Arc Started: %s" % arc.get_arc_name()
	if arc.protagonist_id:
		var card = DataManager.get_card_data(arc.protagonist_id)
		if card:
			msg += " (%s)" % card.display_name
	
	show_notification(msg, Color(1, 0.8, 0.2)) # Gold

func _on_arc_progressed(arc: StoryArc, _old_phase: int) -> void:
	var msg = "%s progressed to %s" % [arc.get_arc_name(), arc.get_phase_name()]
	show_notification(msg, Color(0.4, 0.8, 1.0)) # Light Blue

func _on_arc_resolved(arc: StoryArc) -> void:
	var msg = "%s Resolved: %s" % [arc.get_arc_name(), arc.resolution_type.capitalize()]
	var color = Color.GREEN if arc.resolution_type != "tragic" else Color.RED
	show_notification(msg, color)

func _on_title_earned(card_id: String, title: String) -> void:
	var card = DataManager.get_card_data(card_id)
	var name = card.display_name if card else "Someone"
	show_notification("%s earned title: %s" % [name, title], Color(0.9, 0.6, 1.0)) # Purple
