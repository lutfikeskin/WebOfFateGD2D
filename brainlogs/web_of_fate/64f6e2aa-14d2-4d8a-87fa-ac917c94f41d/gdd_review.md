# Web of Fate - GDD Review & Feedback

**Reviewer:** Antigravity (AI Game Dev Assistant)  
**Date:** 2025-11-21  
**Subject:** Game Design Document v1.0 Analysis

---

## 1. Executive Summary

The "Web of Fate" GDD presents a solid foundation for a compelling roguelike. The **5-slot spread mechanic** combined with the **Legacy vs. Chaos** tension creates a unique strategic layer that differentiates it from market leaders like *Balatro* or *Slay the Spire*. The scope is well-managed for a solo/small team using Godot 4.5, particularly with the proposed Resource-based architecture.

**Verdict:** **Green Light**. The core loop is sound, and the technical approach is optimal for the engine. The main risks lie in balancing the "Death Spiral" of Chaos and ensuring the UI clearly communicates complex probability chains.

---

## 2. Strengths

### Core Mechanics
- **Spatial Strategy:** The 5-slot cross layout adds a 2D spatial puzzle element (diagonals, rows) often missing in linear card battlers. This opens up design space for "adjacency" and "shape-based" combos.
- **Dual Risk System:** The tension between **Legacy** (Greed/Score) and **Chaos** (Penalty/Difficulty) is a strong emotional hook. It forces players to decide between "playing it safe" or "pushing for a high score" at the risk of ruining future turns.
- **Momentum:** The "Success breeds success" mechanic (Momentum bonus) encourages sequencing cards from high-probability to low-probability, adding depth to the placement phase.

### Technical Architecture
- **Resource-First Approach:** Using Godot's `Resource` system (`.tres` files) for Cards, Combos, and Relics is the perfect choice. It allows for:
    - Rapid content iteration without code changes.
    - Easy modding support in the future.
    - Visual editing in the Godot Inspector.
- **Separation of Concerns:** The split between `GameManager` (logic) and `SimpleGameController` (presentation) is good practice and will make the code easier to maintain.

---

## 3. Critical Feedback & Risks

### A. The "Death Spiral" Risk
**Issue:** Chaos reduces success chance -> Lower success chance leads to failures -> Failures generate more Chaos.
**Risk:** Once a player falls behind, it may feel mathematically impossible to recover, leading to frustration rather than "tough choices."
**Suggestion:**
- **Comeback Mechanics:** Ensure "Love" cards (Chaos reduction) are accessible or draftable when Chaos is high.
- **Chaos "Venting":** Consider a mechanic to "spend" Legacy to reduce Chaos, or a "Sacrifice" slot that guarantees Chaos reduction but gives 0 Legacy.

### B. Probability Transparency (UI/UX)
**Issue:** The "Effective Chance" formula involves dynamic variables (`Success Count * 5`).
**Risk:** Players cannot easily calculate the probability of the 4th or 5th card in their head because it depends on the *outcome* of the previous cards.
**Suggestion:**
- **Dynamic Tooltips:** Hovering a slot should show "Min/Max Chance" (e.g., "40% (if previous fail) - 60% (if previous succeed)").
- **Simulation Mode:** A "Preview" button that runs the math 1000 times and shows "Expected Legacy" and "Expected Chaos" ranges could be a high-value feature (like *Balatro's* score preview).

### C. Hand Management
**Issue:** The GDD says "Used cards -> Discard" but doesn't explicitly state what happens to *unused* cards in hand.
**Clarification Needed:** Do I keep my best cards for the next spread? Or is the whole hand discarded?
- **If Keep:** Players will hoard "Exodia" combos, potentially stalling the game.
- **If Discard All:** It forces tactical improvisation (Roguelike standard).
**Recommendation:** **Discard All** is usually better for pacing in this genre, perhaps with a Relic that allows "Retaining" 1 card.

---

## 4. Technical Recommendations (Godot 4.5)

### 1. Custom Resources & `class_name`
Ensure all data types use `class_name` (e.g., `class_name CardData extends Resource`). This enables type safety and better Inspector integration.

### 2. Signal Bus Pattern
For the "Visual Feedback" section, use a global `SignalBus` autoload.
- `SignalBus.card_resolved.emit(card, success)`
- `SignalBus.combo_triggered.emit(combo_id)`
- `SignalBus.chaos_changed.emit(new_value)`
This decouples the UI (`SimpleGameController`) from the Logic (`GameManager`).

### 3. Command Pattern for Resolution
Since resolution is sequential and visual (popups, shakes), consider using a `CommandQueue` or `await` pattern for the `SpreadResolver`.
- `await resolve_slot(tl_slot)`
- `await play_animation("success")`
- `await resolve_slot(tr_slot)`
This prevents animation overlapping and makes the "drama" of the resolution readable.

---

## 5. Proposed Next Steps

1.  **Project Setup:** Initialize the Godot 4.5 project with the folder structure defined in "Technical Architecture".
2.  **Data Layer:** Create the `CardData`, `ComboData`, and `PathData` scripts (`.gd`).
3.  **Core Loop Prototype:** Implement the "Draw -> Place -> Resolve" loop with placeholder UI (ColorRects).
4.  **Visual Polish:** Once the math works, apply the "Web" shaders and card art.

---
