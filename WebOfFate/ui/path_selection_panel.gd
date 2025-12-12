extends PanelContainer

## Path Selection Panel - Shown at run start for player to choose their path

signal path_selected(path: BidData)

@onready var title_label: Label = %TitleLabel
@onready var paths_container: HBoxContainer = %PathsContainer

func _ready() -> void:
	visible = false

## Show the path selection UI
func show_paths() -> void:
	# Clear previous
	for child in paths_container.get_children():
		child.queue_free()
	
	# Create path cards
	var paths := BidData.get_all_paths()
	for path in paths:
		_create_path_card(path)
	
	visible = true

func _create_path_card(path: BidData) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 280)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	card.add_child(vbox)
	
	# Path name
	var name_label := Label.new()
	name_label.text = path.path_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", path.get_path_color())
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# Separator
	var sep := HSeparator.new()
	vbox.add_child(sep)
	
	# Description
	var desc_label := Label.new()
	desc_label.text = path.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)
	
	# Modifiers display
	var mods_label := Label.new()
	var mods_text := ""
	if path.dp_multiplier != 1.0:
		var sign_str = "+" if path.dp_multiplier > 1.0 else ""
		mods_text += "DP: %s%d%%\n" % [sign_str, int((path.dp_multiplier - 1.0) * 100)]
	if path.chaos_multiplier != 1.0:
		var sign_str = "+" if path.chaos_multiplier > 1.0 else ""
		mods_text += "Chaos: %s%d%%\n" % [sign_str, int((path.chaos_multiplier - 1.0) * 100)]
	if path.event_frequency_multiplier != 1.0:
		mods_text += "Events: x%.1f\n" % path.event_frequency_multiplier
	if path.legendary_rate_multiplier != 1.0:
		mods_text += "Legendaries: x%.1f\n" % path.legendary_rate_multiplier
	
	mods_label.text = mods_text.strip_edges()
	mods_label.add_theme_font_size_override("font_size", 11)
	mods_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.6))
	vbox.add_child(mods_label)
	
	# Select button
	var btn := Button.new()
	btn.text = "Choose Path"
	btn.pressed.connect(func(): _on_path_chosen(path))
	vbox.add_child(btn)
	
	# Add hover effect
	card.mouse_entered.connect(func(): card.modulate = Color(1.2, 1.2, 1.2))
	card.mouse_exited.connect(func(): card.modulate = Color.WHITE)
	
	paths_container.add_child(card)

func _on_path_chosen(path: BidData) -> void:
	visible = false
	path_selected.emit(path)
