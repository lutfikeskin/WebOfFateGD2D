# Web of Fate
A Godot 4.5 narrative deckbuilder about weaving destiny on a 5-slot loom. Built with a data-driven architecture, emergent Chronicle system, and fully localized (EN/TR).

## Core Loop
- **Preparation**: Draw to hand, review board (Sticky Web keeps unmatched cards).
- **Placement**: Place cards on 5-slot Loom; cards played this turn can be moved.
- **Weaving**: Resolve synergies, gain Destiny Points (DP), add Chaos, apply passives, discard synergized cards, lock unmatched cards.
- **Resolution**: Update UI, lock prior-turn cards, advance turn/chapters, trigger events.

## Highlight Features
- **Emergent Narrative (Chronicle System)**: Entity moods/titles, relationships, story arcs (Heroic Journey, Corruption, Romance, Tragedy, Revenge, etc.), run endings via `run_ending.gd`.
- **Synergy System**: Named and tag-based synergies with thread-type modifiers; negative synergies supported.
- **Sticky Web Mechanic**: Unmatched cards persist and lock future slots.
- **Progression**: Multiple endings, card rarity, path/bid system, fate events, hand mulligan.
- **Localization**: English/Turkish via `translations/translations.csv`.
- **Tooling**: Content generator scripts for cards/synergies, VFX helpers, toast notifications, intent lines.

## Project Structure
- `WebOfFate/`
  - `logic/` — managers (game, turn, loom, synergy, chronicle, narrative, fate events, save, audio, tooltip).
  - `components/` — table UI, slots, hand, thread renderer, screen shake.
  - `data/` — cards, synergies, decks, chapters (`.tres` resources).
  - `resources/` — data classes (card_data, synergy_data, story_arc, run_ending, etc.).
  - `ui/` — main menu, panels (chronicle, path selection, hand selection, fate event popup), tutorial.
  - `vfx/` — synergy/chaos/dissolve particles.
- `addons/simple_cards/` — upstream card UI plugin used by the project.
- `translations/` — CSV and generated translation assets.
- `web_of_fate_comprehensive_gdd.md` — full game design document.
- `brainlogs/web_of_fate/` — archived dev session notes.

## Run the Game
1. Install **Godot 4.5**.
2. Open `project.godot`.
3. Ensure `addons/simple_cards` plugin is enabled (Project Settings → Plugins).
4. Play the main scene: `WebOfFate/WebOfFate.tscn`.

## Data-Driven Content
- Cards, synergies, chapters, bids/paths, fate events defined as `.tres` under `WebOfFate/data/`.
- Resource classes under `WebOfFate/resources/` (typed GDScript).
- Use `WebOfFate/tools/content_generator.gd` for batching new cards/synergies.

## Key Systems (Autoloads)
- `GameManager` — run state, chapters, endings.
- `TurnManager` — turn/phase flow.
- `LoomManager` — board/threads, slot access.
- `SynergyCalculator` — DP/Chaos resolution, negative synergies.
- `ChronicleManager` — emergent narrative, memories, relationships, arcs, endings.
- `NarrativeManager` — story text generation.
- `FateEventManager` — timed events.
- `SaveManager` — persistence.
- `AudioManager`, `TooltipManager`.

## Controls & UX
- Drag cards from hand to slots; right-click sacrifice (Sever Thread) where available.
- Hover for tooltips; intent lines show potential connections.
- Chronicle Panel at chapter end/game over; fate event popups mid-run.

## Localization
- Strings come from `translations/translations.csv`; use `tr()` in code.
- Provided locales: `en`, `tr`. Add columns for new languages, reimport in Godot.

## Development Notes
- Engine: Godot 4.5, typed GDScript.
- Patterns: autoload managers, signals, data via Resources; UI is presentation-only.
- Testing: run `WebOfFate.tscn`; verify synergies, Chronicle updates, endings, translations.

## Credits
- Built on top of the **Simple Cards** addon (included in `addons/simple_cards`).
- Game design and code: Web of Fate team.
