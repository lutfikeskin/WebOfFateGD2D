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
	"default": [
		"{0} interacted with {1}.",
		"Fate wove {0} and {1} together.",
		"{0} and {1} crossed paths."
	]
}

func generate_turn_log(synergy_result: Dictionary) -> String:
	return synergy_result.get("log", "")

func generate_chapter_prophecy(cards_played: Array) -> String:
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

func _has_card_name(list: Array[CardData], name: String) -> bool:
	for c in list:
		if c.display_name == name:
			return true
	return false
