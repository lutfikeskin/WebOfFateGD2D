class_name RunEnding extends Resource

## Represents a possible ending for a run.
## Determined by dominant story arcs and player statistics.

enum EndingType {
	HEROS_TRIUMPH, ## Heroic Journey + Low Chaos
	PYRRHIC_VICTORY, ## Heroic Journey + High Chaos
	FALL_INTO_DARKNESS, ## Corruption dominant
	LOVES_TRIUMPH, ## Romance completed
	WEEPING_OF_FATES, ## Tragedy dominant
	REDEMPTION_ARC, ## Redemption completed
	BLOOD_VENDETTA, ## Revenge completed
	BROKEN_BONDS, ## Betrayal dominant
	NOBLE_END, ## Sacrifice dominant
	MASTER_WEAVER, ## High DP, no clear arc
	TANGLED_THREADS ## Low performance, default
}

@export var ending_type: EndingType = EndingType.TANGLED_THREADS
@export var title: String = ""
@export var description: String = ""
@export var is_victory: bool = true
@export var bonus_dp: int = 0

## Create ending from chronicle data
static func determine_ending(chronicle: ChronicleData, final_chaos: int, max_chaos: int) -> RunEnding:
	var ending := RunEnding.new()
	
	# Analyze arcs
	var dominant_arc := _get_dominant_arc(chronicle)
	var chaos_ratio := float(final_chaos) / float(max_chaos) if max_chaos > 0 else 0.0
	var high_chaos := chaos_ratio >= 0.7
	
	# Determine ending based on dominant arc
	match dominant_arc:
		StoryArc.ArcType.HEROIC_JOURNEY:
			if high_chaos:
				ending.ending_type = EndingType.PYRRHIC_VICTORY
				ending.title = "Pyrrhic Victory"
				ending.description = "The hero prevailed, but at what cost? The threads of fate are stained with chaos."
				ending.bonus_dp = 50
			else:
				ending.ending_type = EndingType.HEROS_TRIUMPH
				ending.title = "The Hero's Triumph"
				ending.description = "Through trials and tribulations, the hero's destiny was woven with glory!"
				ending.bonus_dp = 100
		
		StoryArc.ArcType.CORRUPTION:
			ending.ending_type = EndingType.FALL_INTO_DARKNESS
			ending.title = "Fall into Darkness"
			ending.description = "The shadows claimed another soul. The web of fate grows darker..."
			ending.is_victory = false
			ending.bonus_dp = 25
		
		StoryArc.ArcType.REDEMPTION:
			ending.ending_type = EndingType.REDEMPTION_ARC
			ending.title = "Path to Redemption"
			ending.description = "From darkness arose light. The fallen one has been redeemed!"
			ending.bonus_dp = 150
		
		StoryArc.ArcType.ROMANCE:
			ending.ending_type = EndingType.LOVES_TRIUMPH
			ending.title = "Love Conquers All"
			ending.description = "Two hearts intertwined, their fates bound forever in the web of destiny."
			ending.bonus_dp = 75
		
		StoryArc.ArcType.TRAGEDY:
			ending.ending_type = EndingType.WEEPING_OF_FATES
			ending.title = "The Weeping of Fates"
			ending.description = "Doom was written in the stars. Some threads are destined to be cut short."
			ending.is_victory = false
			ending.bonus_dp = 30
		
		StoryArc.ArcType.REVENGE:
			ending.ending_type = EndingType.BLOOD_VENDETTA
			ending.title = "Blood Vendetta"
			ending.description = "Vengeance was served. But does the cycle of violence ever truly end?"
			ending.bonus_dp = 60
		
		StoryArc.ArcType.BETRAYAL:
			ending.ending_type = EndingType.BROKEN_BONDS
			ending.title = "Broken Bonds"
			ending.description = "Trust shattered like glass. The web trembles with deception."
			ending.bonus_dp = 40
		
		StoryArc.ArcType.SACRIFICE:
			ending.ending_type = EndingType.NOBLE_END
			ending.title = "Noble Sacrifice"
			ending.description = "One thread was cut so others might shine. A hero's end in the truest sense."
			ending.bonus_dp = 120
		
		_:
			# No clear dominant arc - judge by performance
			if chronicle.total_synergies >= 15:
				ending.ending_type = EndingType.MASTER_WEAVER
				ending.title = "Master Weaver"
				ending.description = "Though no single story dominated, a masterful tapestry was woven."
				ending.bonus_dp = 80
			else:
				ending.ending_type = EndingType.TANGLED_THREADS
				ending.title = "Tangled Threads"
				ending.description = "The web of fate remains unclear. Perhaps destiny requires another attempt."
				ending.is_victory = false
				ending.bonus_dp = 10
	
	return ending

## Find the most prominent arc type
static func _get_dominant_arc(chronicle: ChronicleData) -> int:
	var arc_counts := {}
	
	# Count completed arcs by type
	for arc in chronicle.completed_arcs:
		var arc_type: int = arc.arc_type
		arc_counts[arc_type] = arc_counts.get(arc_type, 0) + 2 # Completed arcs count double
	
	# Count active arcs
	for arc in chronicle.active_arcs:
		var arc_type: int = arc.arc_type
		arc_counts[arc_type] = arc_counts.get(arc_type, 0) + 1
	
	# Find dominant
	var dominant := -1
	var max_count := 0
	for arc_type in arc_counts:
		if arc_counts[arc_type] > max_count:
			max_count = arc_counts[arc_type]
			dominant = arc_type
	
	return dominant
