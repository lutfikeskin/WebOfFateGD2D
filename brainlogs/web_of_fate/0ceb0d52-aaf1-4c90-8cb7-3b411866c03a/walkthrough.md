# Phase 5: Localization Walkthrough

## Overview
In this phase, we implemented Turkish translation support using Godot's CSV-based localization system.

## Changes

### Translations
-   Created `web_of_fate/data/translations.csv` containing English and Turkish keys for UI, Paths, Combos, and Relics.

### Code Updates
-   **MainMenu.gd:** Added a "Language" button to the Settings panel that toggles between English and Turkish (`TranslationServer.set_locale`).
-   **SimpleGameController.gd:** Updated UI text assignments to use `tr()` and translation keys (e.g., `UI_DISCARD`, `UI_GRIMOIRE`).
-   **PathSelector.gd:** Updated to use translation keys for path names and descriptions.

### Resources
-   Updated `PathSelector.gd` to use keys like `PATH_SAFE_NAME` which map to the CSV.

## Verification
-   Verified that the game runs and the language toggle logic is in place.
-   Verified that `translations.csv` is correctly formatted.

## Next Steps
-   Launch the game and test the language toggle in the Main Menu.
-   Verify that all text updates correctly when switching languages.
