# Game Loop & Progression Design

## Goal
Clarify and implement the core game loop: **Draw -> Play -> Score -> Progress**.
Structure the game into "Ages" (similar to Balatro's Antes) where the player must reach a target score to proceed.

## Core Loop

### 1. Run Start
-   **Deck**: Initialize with a standard starter deck (e.g., 22 Major Arcana + some Minor Arcana).
-   **State**: Age 1, Target Score 1000.

### 2. Turn Sequence
1.  **Draw Phase**: Player draws up to Hand Size (default 5).
2.  **Play Phase**: Player places 4 cards into the Web Slots (TL, TR, BL, BR).
3.  **Resolution Phase**:
    -   Click "Resolve".
    -   Calculate Score = `(Base Legacy) * (Multiplier)`.
    -   Add Score to `Current Age Score`.
    -   **Visuals**: Juice effects play.
4.  **Cleanup Phase**:
    -   Played cards are moved to **Discard Pile**.
    -   Remaining cards in hand are kept (or discarded, depending on design choice. Let's keep them for strategy).
    -   Draw cards until Hand Size is reached.
    -   **Check End Conditions**:
        -   If `Current Age Score >= Target Score`: **Age Won**.
        -   If `Deck Empty` (and can't draw full hand?): **Game Over** (or reshuffle discard pile once per Age?). Let's allow **1 Reshuffle** per Age or have a "Doom" counter. For now: **Reshuffle Discard Pile** when Deck is empty.

### 3. Age Progression
-   **Age Won**:
    -   Show "Age Complete" summary.
    -   **Shop Phase**:
        -   Buy **Relics** (Passive bonuses).
        -   Buy **Tarot Cards** (Consumables or Deck Enhancements).
        -   Remove Cards (Burn).
    -   **Next Age**:
        -   Increase Age Counter.
        -   Increase Target Score (Exponential scaling).
        -   Reset `Current Age Score` to 0.

## Implementation Plan

### 1. GameManager Updates
-   Add `current_age` (int).
-   Add `target_score` (float).
-   Add `current_age_score` (float).
-   Add `discard_pile` (managed by DeckManager).
-   Implement `check_age_progress()`:
    -   Called after every spread resolution.
    -   Handles Win/Loss logic.

### 2. DeckManager Updates
-   Implement `discard_pile` logic.
-   Update `draw_hand` to reshuffle discard pile if deck is empty.
-   Implement `discard_played_cards(cards)`.

### 3. UI Updates
-   Add **Progression UI**:
    -   "Age: 1"
    -   "Score: 500 / 1000" (ProgressBar).
-   Add **Shop UI** (Basic placeholder for now).

## User Review Required
-   **Reshuffle Logic**: Should the discard pile automatically reshuffle, or is running out of cards a loss condition? (Balatro reshuffles).
    -   *Proposal*: Automatic reshuffle to keep the flow going, but maybe increase Chaos on reshuffle?
-   **Hand Retention**: Do we keep unplayed cards in hand?
    -   *Proposal*: Yes, allows saving good cards for combos.

## Proposed Changes
### GameManager.gd
-   [NEW] `current_age`, `target_score`, `age_score`.
-   [MODIFY] `resolve_spread`: Add cleanup logic and score accumulation.
-   [NEW] `advance_age()`: Handles scaling and shop transition.

### DeckManager.gd
-   [NEW] `discard_pile`: Array[WebOfFateCard].
-   [MODIFY] `draw_hand`: Handle reshuffle.
-   [NEW] `move_to_discard(cards)`.
