class_name EntityState extends Resource

## Tracks persistent state for each card across a run.
## Part of the Chronicle System for emergent narratives.

## Unique instance ID for this card in the current run
@export var instance_id: String = ""
## Reference card ID from CardData
@export var card_id: String = ""

@export_group("Experience")
## Number of times this card has been played on the Loom
@export var times_played: int = 0
## Number of synergies this card participated in
@export var synergies_formed: int = 0
## Card IDs this entity has synergized with
@export var synergy_partners: Array[String] = []
## Number of times this card sat on Loom without forming synergy
@export var tragic_encounters: int = 0
## Highest DP contribution in a single synergy
@export var highest_dp_contribution: int = 0

@export_group("Emotional State")
## Mood ranges from -1.0 (despair) to 1.0 (exalted)
@export_range(-1.0, 1.0) var mood: float = 0.0
## Titles earned through actions (e.g., "the Legendary", "Threadbinder")
@export var earned_titles: Array[String] = []

@export_group("Relationships")
## Card IDs this entity has positive affinity with
@export var bonds: Array[String] = []
## Card IDs this entity has negative affinity with
@export var grudges: Array[String] = []

## Generate a unique instance ID
static func generate_instance_id(p_card_id: String) -> String:
	return "%s_%d" % [p_card_id, Time.get_unix_time_from_system()]

## Get display name with title if earned
func get_titled_name(base_name: String) -> String:
	if earned_titles.is_empty():
		return base_name
	return "%s %s" % [base_name, earned_titles[0]]

## Update mood based on synergy outcome
func adjust_mood(synergy_success: bool, dp_gained: int) -> void:
	if synergy_success:
		mood = clampf(mood + 0.1 + (dp_gained * 0.002), -1.0, 1.0)
	else:
		mood = clampf(mood - 0.1, -1.0, 1.0)

## Check and award titles based on achievements
func check_titles() -> String:
	var new_title := ""
	
	# Synergy Master: 10+ synergies
	if synergies_formed >= 10 and not earned_titles.has("the Weaver"):
		earned_titles.append("the Weaver")
		new_title = "the Weaver"
	
	# High achiever: DP > 80 in single synergy
	if highest_dp_contribution >= 80 and not earned_titles.has("the Legendary"):
		earned_titles.append("the Legendary")
		new_title = "the Legendary"
	
	# Survivor: played 15+ times
	if times_played >= 15 and not earned_titles.has("the Enduring"):
		earned_titles.append("the Enduring")
		new_title = "the Enduring"
	
	return new_title
