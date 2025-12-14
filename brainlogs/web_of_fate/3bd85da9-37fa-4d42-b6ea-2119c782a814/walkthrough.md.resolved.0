# Custom Resource Architecture Walkthrough

I have successfully implemented a Custom Resource architecture for the Web of Fate card system. This replaces the old JSON-based system with a more robust, editor-friendly, and extensible Godot Resource system.

## What Changed?

### 1. New Resource Types
We now have three main resource types that you can create and edit directly in the Godot Inspector:

-   **[CardData](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/resources/CardData.gd)**: Defines a card's properties (stats, tags, effects).
-   **[ComboData](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/resources/ComboData.gd)**: Defines combo rules (positions, sequences) and effects.
-   **[DeckData](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/resources/DeckData.gd)**: Defines a starting deck list.

### 2. New Autoload Managers
Two new autoloads manage these resources:

-   **[CardDB](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/autoloads/CardDB.gd)**: Automatically loads all `.tres` files from `res://web_of_fate/data/cards/`.
    -   Use `CardDB.get_card("card_id")` to access card data.
-   **[ComboDB](file:///c:/Users/Lutfi/Desktop/Godot/Assets/simple-card-pile-ui-master/simple-card-pile-ui-master/web_of_fate/scripts/autoloads/ComboDB.gd)**: Automatically loads all `.tres` files from `res://web_of_fate/data/combos/`.
    -   Use `ComboDB.get_position_combos()` to get all position-based combos.

### 3. Generated Content
I have generated `.tres` files for:
-   **34 Cards**: Including Danger, Ally, Mystic, Love, Chaos, and Resource types.
-   **9 Combos**: Including Row Synergy, Column Strength, and Sequence combos.

These files are located in:
-   `res://web_of_fate/data/cards/`
-   `res://web_of_fate/data/combos/`

## How to Use

### Creating a New Card
1.  Right-click in the FileSystem dock in Godot.
2.  Select **Create New > Resource**.
3.  Search for **CardData**.
4.  Fill in the properties (ID, Name, Type, Stats, Tags).
5.  Save it in `res://web_of_fate/data/cards/`.
6.  It will be automatically loaded by `CardDB` on game start!

### Creating a New Combo
1.  Right-click and create a new **ComboData** resource.
2.  Define the `Required Tags` (e.g., `["fire", "danger"]`).
3.  Define `Positions` (e.g., `["horizontal"]` for row neighbors).
4.  Define `Effects` (Legacy Multiplier, Bonus, etc.).
5.  Save it in `res://web_of_fate/data/combos/`.

### Editing Existing Cards
Simply double-click any `.tres` file in `res://web_of_fate/data/cards/` to edit its balance values in the Inspector. No more JSON editing!

## Verification
I ran a verification script `res://web_of_fate/scripts/tests/verify_resources.gd` which confirmed:
-   `CardDB` correctly loads all 34 generated cards.
-   `ComboDB` correctly loads all 9 generated combos.
-   Specific data (like "Faultline" stats) matches the requirements.

## Next Steps
-   **Update UI**: The card UI currently displays basic info. You can now bind more rich data (like tooltips showing upgrade paths) using the `CardData` resource.
-   **Implement Special Effects**: The `special_effect` string in `CardData` is currently just a string. You'll need to implement a handler in `SpreadResolver` or `GameManager` to trigger actual logic for effects like "shake_neighbors" or "burn_neighbors".
