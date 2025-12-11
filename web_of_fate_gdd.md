---
description: "Core project context and patterns"
globs:
alwaysApply: true
---

# Web of Fate GDD

## 1. Game Overview
**Title:** Web of Fate
**Genre:** Card Game / Puzzle / Narrative
**Platform:** PC (Godot 4)
**Target Audience:** Strategy and story-driven game lovers.

## 2. Core Gameplay Loop
1.  **Preparation Phase:** Players start with a hand of cards (Actors, Items, Events, Locations).
2.  **Weaving Phase:** Players place cards into a 5-slot "Loom" (Game Table).
3.  **Connection Logic:** Slots are connected by "Threads". Placing cards creates interactions based on:
    *   **Tags:** Matching tags (e.g., "Heroic" + "Weapon") create generic synergies.
    *   **Combos:** Specific pairs (e.g., "Romeo" + "Juliet") create unique story events.
4.  **Resolution Phase:**
    *   **Synergy:** Successful combinations generate Destiny Points (DP) and are removed from the board (Discarded).
    *   **Sticky Web:** Unmatched cards stay on the board, clogging slots.
    *   **Chaos:** Some cards or interactions generate Chaos. If Chaos reaches max, the game ends.
5.  **Progression:** Collect enough DP to complete the Chapter.

## 3. Key Mechanics
*   **Sticky Web:** The board is not cleared automatically. You must "solve" the cards you placed.
*   **Threads:** Visual lines connecting slots. Different thread types (Red, Gold, etc.) modify interactions.
*   **Chaos Management:** Risk/Reward mechanic. High power often comes with High Chaos.

## 4. Systems & Architecture
*   **Data Driven:** All cards, synergies, and chapters are defined as `Resource` files.
*   **Managers:**
    *   `GameManager`: Global state, level progression.
    *   `TurnManager`: Turn phases (Input -> Weaving -> Resolution).
    *   `LoomManager`: Board state and connections.
    *   `DataManager`: Loading and serving resources.
    *   `CardDeckManager`: Deck lists, drawing, discarding.

## 5. Progression & Polish (New Features)
### 5.1 Drafting System (Deckbuilding)
*   At the end of each successful chapter, the player enters a **Draft Phase**.
*   **Selection:** 3 random cards are presented from the unlocked pool.
*   **Choice:** Player chooses 1 card to permanently add to their deck for the run.
*   **Goal:** Allows specializing the deck (e.g., focusing on "Violence" or "Romance" synergies).

### 5.2 Visual Polish (Juice)
*   **Screen Shake:** Triggers on high-impact events (Big Synergies, Game Over, High Chaos).
*   **Card Dissolve:** Cards shouldn't just vanish. They should burn away or unravel into threads when discarded.
*   **Thread Snap:** Visual feedback when a connection is broken or resolved.
*   **Audio:** (Future) Dynamic music layers based on Chaos level.

### 5.3 UX Enhancements
*   **Intent Lines (Ghost Threads):** When dragging a card over a slot, show semi-transparent lines indicating potential connections *before* dropping.
*   **Tooltips:** Hovering over a card explains its Tags and keywords.

### 5.4 Narrative System
*   **Dynamic Prophecies:** Instead of static logs, the game generates a "Prophecy" text based on the cards played in a chapter.
*   **Template:** "The union of [Card A] and [Card B] brought [Result]..."
