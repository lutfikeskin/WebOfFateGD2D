# Implementation Plan - Phase 5: Localization

## Goal Description
Implement Turkish translation support using Godot's CSV-based localization system.

## User Review Required
> [!NOTE]
> I will be creating a `translations.csv` file. Godot automatically imports this as a translation resource.

## Proposed Changes

### `web_of_fate/data`

#### [NEW] [translations.csv](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/data/translations.csv)
-   **Columns:** `keys`, `en`, `tr`
-   **Content:** All UI text, card names, descriptions, etc.

### `web_of_fate/scripts`

#### [MODIFY] [MainMenu.gd](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/MainMenu.gd)
-   **Update:** Add language selection logic to Settings.

#### [MODIFY] [SimpleGameController.gd](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/SimpleGameController.gd)
-   **Update:** Ensure dynamic text (like button labels with numbers) uses `tr()` or format strings correctly.

#### [MODIFY] [PathSelector.gd](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/PathSelector.gd)
-   **Update:** Use translation keys for generated path descriptions if they are not resources. (Actually, they are resources now, so I need to update the resources).

### Resources
-   **Strategy:** I will update the `.tres` files for Paths, Combos, and Relics to use Translation Keys (e.g., `PATH_WARRIOR_NAME`) instead of raw text.

## Verification Plan

### Manual Verification
1.  **Language Switch:** Go to Settings -> Change Language -> Verify text changes.
2.  **Gameplay:** Play a run -> Verify cards, paths, and UI elements are translated.
