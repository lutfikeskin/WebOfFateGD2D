class_name ChapterData extends Resource

@export var chapter_name: String = "Chapter 1"
@export_multiline var description: String = "The beginning of fate."
@export_multiline var narrative_intro: String = "" # Narrative text shown at start
@export var target_dp: int = 100
@export var max_chaos: int = 100
@export var max_turns: int = 10
@export var starting_deck: CardDeck # Optional override for specific chapters
