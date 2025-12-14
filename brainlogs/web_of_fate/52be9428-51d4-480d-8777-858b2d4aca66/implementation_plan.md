# Implementation Plan - Refactor & Content Expansion

## Goal
Transition the game from a Balatro-like "Age/Blind" structure to a pure "Path" based progression system. Expand the content with 50 new cards and 10 new paths.

## Proposed Changes

### Game Loop Refactor
#### [MODIFY] [GameManager.gd](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/GameManager.gd)
- Remove `current_age`, `current_blind`, `target_score`, `ante_scaling` variables.
- Remove `check_age_progress`, `_on_blind_cleared`, `next_round`.
- Update `start_run` to require a `PathData`.
- Ensure `resolve_spread` only updates Path progress.

#### [MODIFY] [SimpleGameController.gd](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/SimpleGameController.gd)
- Remove `_on_age_changed`, `_on_age_score_changed`.
- Update UI to display Path Progress (Legacy / Goal) instead of Age Score.
- Ensure `_check_and_auto_draw` respects the new flow.

### Content Expansion
#### [NEW] [Paths]
- Create 10 new `.tres` files in `web_of_fate/data/paths/`.
- Themes: The Void, The Weaver, The King, The Hermit, etc.

#### [NEW] [Cards]
- Create 50 new `.tres` files in `web_of_fate/data/cards/`.
- Categories: Major Arcana, Weaving Tools, Elements, Fate Concepts.

#### [NEW] [Combos]
- Create new `.tres` files in `web_of_fate/data/combos/`.
- Define synergies based on the new card tags (e.g., "The Three Fates", "Elemental Harmony").

## Verification Plan
- Run the game and verify that the Age/Blind UI is gone.
- Start a run and verify it requires a Path.
- Check that new cards appear in the deck/draw pile.
- Verify Path progress updates correctly.
