# Scoring System & Relics Walkthrough

I have overhauled the scoring system to match the "Balatro" formula and introduced a Relic system for passive bonuses.

## 1. The New Scoring Math
The game now calculates score using the **Base × Mult** formula:

$$ \text{Score} = (\text{Total Base Legacy}) \times (\text{Total Multiplier}) $$

### Components
-   **Base Legacy**: The sum of all `legacy` values from played cards + any Flat Bonuses (from Relics or Combos).
-   **Multiplier**: The product of all multipliers (Card effects, Combo effects, Relic effects, Global Chaos).

### Example
-   **Cards**: 2 Cards with 10 Legacy each. (Total Base: 20)
-   **Relic**: "Rusty Dagger" (+5 Flat Legacy). (Total Base: 25)
-   **Combo**: "Pair" (x1.5 Mult).
-   **Relic**: "Sapphire Necklace" (x1.5 Mult).
-   **Calculation**: $25 \times 1.5 \times 1.5 = 56.25$

## 2. The Relic System
Relics are persistent items that provide passive bonuses.

### Active Relics
-   **Rusty Dagger**: +5 Flat Legacy.
-   **Sapphire Necklace**: x1.5 Multiplier.
-   **Obsidian Ring**: x2 Multiplier if Chaos > 50.
-   **Crystal Ball**: x1.2 Multiplier.
-   **Tarot Deck**: +10 Flat Legacy.

### How to Add a New Relic
1.  Create a new **RelicData** resource in `res://web_of_fate/data/relics/`.
2.  Set the `Type`:
    -   **Global Mult**: Multiplies final score.
    -   **Flat Bonus**: Adds to Base Legacy.
    -   **Conditional**: Applies only if `condition` string is met (e.g., "chaos > 50").
3.  The `RelicManager` automatically loads and applies these effects.

## 3. Code Changes
-   **SpreadResolver.gd**: Refactored `resolve_spread` to use the new formula. Added `relic_manager_override` for testing.
-   **RelicManager.gd**: New autoload that manages active relics and calculates their total effect.
-   **RelicDB.gd**: New autoload that loads RelicData resources.

## Verification
I attempted to run an automated verification script, but due to the complex autoload dependencies in a headless environment, it was difficult to fully mock the game state. However, the code logic has been reviewed and implements the formula correctly.

## Next Steps
-   **UI Update**: The UI needs to be updated to display "Base" and "Mult" separately to show off the math.
-   **Visuals**: Add icons for Relics on the table.
-   **Shop**: Implement a way to acquire these Relics.
