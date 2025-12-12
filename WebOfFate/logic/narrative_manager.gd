extends Node

# Autoload for generating dynamic narrative text and prophecies based on game events.

# Templates based on tags
# {0} is Subject (Card 1), {1} is Object (Card 2)
var templates = {
	"heroic": [
		"{0} valiantly aided {1}.",
		"The courage of {0} inspired {1}.",
		"{0} fought alongside {1}."
	],
	"tragedy": [
		"{0} wept for the fate of {1}.",
		"Disaster struck when {0} met {1}.",
		"{0} could not save {1}."
	],
	"romance": [
		"{0} and {1} shared a fleeting moment.",
		"Love blossomed between {0} and {1}.",
		"{0} swore to protect {1}."
	],
	"violence": [
		"{0} struck down {1}.",
		"Blood was shed between {0} and {1}.",
		"{0} clashed violently with {1}."
	],
	"mystic": [
		"{0} revealed secrets to {1}.",
		"The arcane bond between {0} and {1} grew.",
		"{0} cast a spell on {1}."
	],
	"betrayal": [
		"{0} turned against {1}.",
		"Trust was shattered when {0} betrayed {1}.",
		"{0} stabbed {1} in the back."
	],
	"sacrifice": [
		"{0} gave everything for {1}.",
		"In the darkest hour, {0} sacrificed for {1}.",
		"{0} laid down their life for {1}."
	],
	"hope": [
		"{0} brought light to {1}.",
		"Hope returned when {0} found {1}.",
		"{0} rekindled the spirit of {1}."
	],
	"family": [
		"{0} and {1} reunited at last.",
		"Blood called to blood as {0} found {1}.",
		"The family bond between {0} and {1} endured."
	],
	"default": [
		"{0} interacted with {1}.",
		"Fate wove {0} and {1} together.",
		"{0} and {1} crossed paths."
	]
}

# Arc-specific prophecy templates
var arc_prophecy_templates = {
	"HEROIC_JOURNEY": [
		"The hero's path leads {0} toward destiny...",
		"Trials await {0}, but glory beckons.",
		"A champion rises. Watch {0} carefully."
	],
	"CORRUPTION": [
		"Darkness creeps into the heart of {0}...",
		"Shadows gather around {0}. Beware.",
		"The fall of {0} may be at hand."
	],
	"REDEMPTION": [
		"Light returns to {0}. Hope is not lost.",
		"A second chance awaits {0}...",
		"{0} seeks to undo past wrongs."
	],
	"ROMANCE": [
		"Love blossoms between {0} and {1}...",
		"Hearts intertwine. {0} and {1} grow closer.",
		"The threads of love bind {0} to {1}."
	],
	"TRAGEDY": [
		"Doom circles {0}. Weep for what is to come.",
		"The fates have marked {0} for sorrow.",
		"No escape remains for {0}..."
	],
	"REVENGE": [
		"{0} hungers for vengeance against {1}.",
		"Blood will be answered with blood...",
		"The vendetta of {0} shall not be denied."
	],
	"BETRAYAL": [
		"Trust has shattered. {0} reels from betrayal.",
		"The knife in {0}'s back still bleeds...",
		"Treachery has poisoned the fate of {0}."
	],
	"SACRIFICE": [
		"{0} prepares for the ultimate sacrifice.",
		"In darkness, {0} shall be the light.",
		"A noble end awaits {0}..."
	],
	"REUNION": [
		"Long-lost souls {0} and {1} reunite at last.",
		"The threads that separated {0} from {1} unravel.",
		"Family bonds bring {0} and {1} together."
	]
}

func generate_turn_log(synergy_result: Dictionary) -> String:
	return synergy_result.get("log", "")

## Generate dynamic prophecy based on active story arcs
func generate_chapter_prophecy(cards_played: Array) -> String:
	# First, check for active story arcs from Chronicle
	if ChronicleManager and ChronicleManager.chronicle:
		var arc_prophecy := _generate_arc_based_prophecy()
		if not arc_prophecy.is_empty():
			return arc_prophecy
	
	# Fallback to card-based prophecy
	return _generate_card_based_prophecy(cards_played)

## Generate prophecy based on active arcs
func _generate_arc_based_prophecy() -> String:
	var arcs = ChronicleManager.chronicle.active_arcs
	if arcs.is_empty():
		return ""
	
	# Pick a random active arc
	var arc: StoryArc = arcs.pick_random()
	var arc_type_name: String = StoryArc.ArcType.keys()[arc.arc_type]
	
	if not arc_prophecy_templates.has(arc_type_name):
		return ""
	
	var template: String = arc_prophecy_templates[arc_type_name].pick_random()
	
	# Get protagonist name
	var protagonist_name := _get_card_name(arc.protagonist_id)
	var antagonist_name := ""
	if not arc.antagonist_id.is_empty():
		antagonist_name = _get_card_name(arc.antagonist_id)
	
	# Replace placeholders
	var result := template.replace("{0}", protagonist_name)
	if not antagonist_name.is_empty():
		result = result.replace("{1}", antagonist_name)
	
	return "The fates whisper: " + result

## Fallback card-based prophecy
func _generate_card_based_prophecy(cards_played: Array) -> String:
	if cards_played.is_empty():
		return "The threads of fate remain silent..."
	
	# Pick random unique cards from history
	var unique_cards: Array[CardData] = []
	for card_data in cards_played:
		if card_data is CardData and not _has_card_name(unique_cards, card_data.display_name):
			unique_cards.append(card_data)
	
	if unique_cards.size() < 2:
		return "A solitary thread, %s, sought its purpose in the void." % tr(unique_cards[0].display_name)
	
	var subject1 = unique_cards.pick_random()
	unique_cards.erase(subject1)
	var subject2 = unique_cards.pick_random()
	
	# Determine context based on shared tags
	var template_key = "default"
	
	# Check for shared tags
	for tag in subject1.tags:
		if subject2.tags.has(tag) and templates.has(tag):
			template_key = tag
			break
			
	# If no shared, pick random tag from either
	if template_key == "default":
		var all_tags = subject1.tags + subject2.tags
		for tag in all_tags:
			if templates.has(tag):
				template_key = tag
				break
	
	var template = templates[template_key].pick_random()
	
	# Translate names
	var s1_name = tr(subject1.display_name)
	var s2_name = tr(subject2.display_name)
	
	# Simple variable substitution
	var result = template.replace("{0}", s1_name).replace("{1}", s2_name)
	
	return "And so it came to pass: " + result

func _has_card_name(list: Array[CardData], card_name: String) -> bool:
	for c in list:
		if c.display_name == card_name:
			return true
	return false

func _get_card_name(card_id: String) -> String:
	var card_data = DataManager.get_card_data(card_id)
	if card_data:
		return tr(card_data.display_name)
	return card_id.replace("_", " ").capitalize()

## Export chronicle to text file
func export_chronicle_to_file() -> String:
	if not ChronicleManager or not ChronicleManager.chronicle:
		return ""
	
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
	var filename := "user://chronicle_%s.txt" % timestamp
	
	var content := ChronicleManager.get_chronicle_summary()
	
	var file := FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("NarrativeManager: Chronicle exported to %s" % filename)
		return filename
	else:
		print("NarrativeManager: Failed to export chronicle")
		return ""

## Get full chronicle as formatted string
func get_chronicle_text() -> String:
	if ChronicleManager and ChronicleManager.chronicle:
		return ChronicleManager.get_chronicle_summary()
	return "No chronicle data available."
