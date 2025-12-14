extends PanelContainer

## Chronicle Panel - Shows run summary at level complete or game over

signal dismissed()

@onready var title_label: Label = %ChronicleTitle
@onready var summary_container: RichTextLabel = %SummaryText
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var close_button: Button = %CloseButton

var current_ending: RunEnding

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	visible = false

## Show the chronicle summary for level complete or game over
func show_chronicle(is_victory: bool = true) -> void:
	# Record the run end in Chronicle
	if is_victory:
		ChronicleManager.record_run_end(
			true,
			"Destiny woven successfully."
		)
	else:
		ChronicleManager.record_run_end(false, "Chaos overwhelmed the Loom.")
	
	# Calculate ending based on Chronicle data
	var max_chaos := GameManager.MAX_CHAOS
	current_ending = RunEnding.determine_ending(
		ChronicleManager.chronicle,
		GameManager.current_chaos,
		max_chaos
	)
	
	# Set title based on ending
	title_label.text = current_ending.title
	
	# Generate and display summary
	_populate_summary()
	_populate_stats()
	
	visible = true

## Generate summary text from ChronicleManager
func _populate_summary() -> void:
	summary_container.clear()
	
	var chronicle := ChronicleManager.chronicle
	
	# Show ending description prominently
	summary_container.append_text("[center][color=gold][b]%s[/b][/color][/center]\n" % current_ending.title)
	summary_container.append_text("[center][i]%s[/i][/center]\n\n" % current_ending.description)
	
	if current_ending.bonus_dp > 0:
		summary_container.append_text("[center][color=green]+%d Bonus DP[/color][/center]\n\n" % current_ending.bonus_dp)
	
	# Opening narrative
	var opening := "In this chapter of fate, %d synergies were woven across %d turns.\n\n" % [
		chronicle.total_synergies,
		chronicle.total_turns
	]
	summary_container.append_text(opening)
	
	# Notable entities
	var notable_entities := _get_notable_entities()
	if not notable_entities.is_empty():
		summary_container.append_text("[b]Heroes of the Loom:[/b]\n")
		for card_id in notable_entities.slice(0, 3):
			var entity: EntityState = chronicle.entity_states[card_id]
			var card_name := _get_card_name(card_id)
			if not entity.earned_titles.is_empty():
				card_name += " " + entity.earned_titles[0]
			var mood_text := _mood_to_emoji(entity.mood)
			summary_container.append_text("• %s - %d synergies %s\n" % [card_name, entity.synergies_formed, mood_text])
		summary_container.append_text("\n")
	
	# Notable relationships
	var notable_rels := chronicle.get_notable_relationships()
	if not notable_rels.is_empty():
		summary_container.append_text("[b]Bonds Forged:[/b]\n")
		for rel in notable_rels.slice(0, 2):
			var name_a := _get_card_name(rel.card_id_a)
			var name_b := _get_card_name(rel.card_id_b)
			var status: String = rel.get_status().replace("_", " ").capitalize()
			summary_container.append_text("• %s & %s - %s\n" % [name_a, name_b, status])
		summary_container.append_text("\n")
	
	# Key moments
	var key_memories := _get_key_memories()
	if not key_memories.is_empty():
		summary_container.append_text("[b]Key Moments:[/b]\n")
		for mem in key_memories.slice(0, 3):
			summary_container.append_text("• %s\n" % mem.narrative_fragment)
		summary_container.append_text("\n")
	
	# Active story arcs
	if not chronicle.active_arcs.is_empty() or not chronicle.completed_arcs.is_empty():
		summary_container.append_text("[b]Story Arcs:[/b]\n")
		for arc in chronicle.active_arcs:
			var protagonist := _get_card_name(arc.protagonist_id)
			var phase := arc.get_phase_name()
			summary_container.append_text("• %s: %s - %s\n" % [arc.get_arc_name(), protagonist, phase])
		for arc in chronicle.completed_arcs:
			var protagonist := _get_card_name(arc.protagonist_id)
			summary_container.append_text("• %s: %s - [color=gold]%s[/color]\n" % [
				arc.get_arc_name(), protagonist, arc.resolution_type.capitalize()
			])

## Populate stats panel
func _populate_stats() -> void:
	# Clear existing
	for child in stats_container.get_children():
		child.queue_free()
	
	var chronicle := ChronicleManager.chronicle
	var stats := chronicle.get_stats_summary()
	
	_add_stat("Total Synergies", str(stats.total_synergies))
	_add_stat("Total Turns", str(stats.total_turns))
	_add_stat("Peak Chaos", str(stats.peak_chaos))
	_add_stat("Highest DP", str(stats.highest_dp))
	_add_stat("Cards Tracked", str(stats.entities_tracked))
	_add_stat("Relationships", str(stats.relationships_formed))

func _add_stat(label_text: String, value: String) -> void:
	var hbox := HBoxContainer.new()
	
	var label := Label.new()
	label.text = label_text + ":"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 14)
	
	var value_label := Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", Color.GOLD)
	
	hbox.add_child(label)
	hbox.add_child(value_label)
	stats_container.add_child(hbox)

func _on_close_pressed() -> void:
	visible = false
	dismissed.emit()

## Helper: Get notable entities sorted by synergy count
func _get_notable_entities() -> Array:
	var chronicle := ChronicleManager.chronicle
	var entities: Array = []
	for card_id in chronicle.entity_states:
		var entity: EntityState = chronicle.entity_states[card_id]
		if entity.synergies_formed >= 1:
			entities.append(card_id)
	
	entities.sort_custom(func(a, b):
		var ea: EntityState = chronicle.entity_states[a]
		var eb: EntityState = chronicle.entity_states[b]
		return ea.synergies_formed > eb.synergies_formed
	)
	
	return entities

## Helper: Get key memories
func _get_key_memories() -> Array[MemoryEntry]:
	var chronicle := ChronicleManager.chronicle
	var key: Array[MemoryEntry] = []
	
	for memory in chronicle.memories:
		match memory.type:
			MemoryEntry.MemoryType.HIGH_DP_MOMENT, \
			MemoryEntry.MemoryType.NEAR_DEATH, \
			MemoryEntry.MemoryType.CHAPTER_VICTORY:
				key.append(memory)
	
	return key

## Helper: Get card display name
func _get_card_name(card_id: String) -> String:
	var card_data = DataManager.get_card_data(card_id)
	if card_data:
		return tr(card_data.display_name)
	return card_id.replace("_", " ").capitalize()

## Helper: Mood to emoji
func _mood_to_emoji(mood: float) -> String:
	if mood >= 0.5:
		return "😊"
	elif mood >= 0.0:
		return "😐"
	elif mood >= -0.5:
		return "😟"
	else:
		return "😢"
