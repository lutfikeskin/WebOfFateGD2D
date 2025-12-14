# Progression Overhaul - Implementation Plan

## Overview

Major system overhaul to address player motivation, puzzle feel, and progression clarity.

---

## Phase 1: Multiple Endings System 🔴 Critical

**Goal**: Give runs meaning through Chronicle-based endings

### Files to Modify/Create:

- [MODIFY] `logic/chronicle_manager.gd` - Add ending calculation
- [NEW] `resources/run_ending.gd` - Ending data resource
- [MODIFY] `ui/chronicle_panel.gd` - Display ending
- [NEW] `data/endings/` - Ending definition files

### Implementation:

```gdscript
# Ending determined by dominant arc type + stats (Path modifiers applied)
func calculate_ending() -> RunEnding:
    var dominant_arc = get_dominant_arc_type()
    var chaos_ratio = peak_chaos / max_chaos
    var synergy_count = total_synergies
    # Returns matching ending
```

**Endings**:
| Dominant Arc | Condition | Ending |
|--------------|-----------|--------|
| Heroic Journey | Low chaos | "The Hero's Triumph" |
| Heroic Journey | High chaos | "Pyrrhic Victory" |
| Corruption | Any | "Fall into Darkness" |
| Romance | Completed | "Love Conquers All" |
| Tragedy | Any | "The Weeping of Fates" |
| Mixed/None | High DP | "Master Weaver" |
| Mixed/None | Low DP | "Tangled Threads" |

---

## Phase 2: Hand Management System 🔴 Critical

**Goal**: Add strategic card selection

### Files to Modify:

- [MODIFY] `logic/turn_manager.gd` - Add draw phase with choice
- [MODIFY] `web_of_fate_controller.gd` - UI for card selection
- [NEW] `ui/card_selection_panel.gd` - Choose cards UI

### Mechanics:

- Draw 7 cards, keep 5 (mulligan system)
- OR: Draw +1 extra, discard 1 before placing

---

## Phase 3: Card Rarity System 🟡 Medium

**Goal**: Power curve and collection depth

### Files to Modify:

- [MODIFY] `resources/card_data.gd` - Add rarity field
- [MODIFY] `card_layouts/web_of_fate_card_layout.gd` - Rarity visuals
- [MODIFY] All card .tres files - Add rarity values

### Rarities:

| Rarity    | Drop Rate | DP Multiplier | Visual             |
| --------- | --------- | ------------- | ------------------ |
| Common    | 60%       | 1.0x          | White border       |
| Rare      | 25%       | 1.3x          | Blue border        |
| Epic      | 12%       | 1.6x          | Purple border      |
| Legendary | 3%        | 2.0x          | Gold border + glow |

---

## Phase 4: Fate Events System 🟡 Medium

**Goal**: Dynamic board state changes

### Files to Create:

- [NEW] `resources/fate_event.gd` - Event data
- [NEW] `logic/fate_event_manager.gd` - Event triggering
- [NEW] `data/fate_events/` - Event definitions
- [NEW] `ui/fate_event_popup.gd` - Event display

### Events (every 3-5 turns):

| Event               | Effect                             |
| ------------------- | ---------------------------------- |
| Solar Eclipse       | All Gold threads → Red for 2 turns |
| Prophecy            | See next 3 cards, reorder them     |
| Fate's Crossroad    | Choose: +20 DP or -20 Chaos        |
| Thread Storm        | All threads randomize colors       |
| Blessing of Harmony | Next synergy: no Chaos             |

---

## Phase 5: Negative Synergies 🟡 Medium

**Goal**: Strategic placement decisions

### Files to Modify:

- [MODIFY] `resources/synergy_data.gd` - Add is_negative flag
- [NEW] `data/synergies/negative/` - Negative synergy files
- [MODIFY] `logic/synergy_calculator.gd` - Handle negatives

### Examples:

| Cards                   | Effect            | Narrative                    |
| ----------------------- | ----------------- | ---------------------------- |
| Holy Knight + Dark Lord | -30 DP, +50 Chaos | "Light and darkness clash!"  |
| Lover + Jealous Prince  | -20 DP, +30 Chaos | "Jealousy poisons the heart" |

---

## Phase 6: Enhanced Sticky Web 🟢 Low

**Goal**: Turn stuck cards into opportunities

### Mechanics:

- Card stuck 3+ turns → "Ripened Fate" bonus (+10 DP on next synergy)
- "Rescue" synergies: Specific cards can free stuck cards
- Stuck cards can form "Waiting Story" synergies with each other

---

## Phase 7: Meta-Progression 🟢 Low

**Goal**: Long-term unlock system

### Files to Create:

- [NEW] `resources/player_profile.gd` - Persistent unlocks
- [NEW] `logic/unlock_manager.gd` - Track achievements
- [MODIFY] `logic/save_manager.gd` - Save profile

### Unlocks:

- New cards (start with 20, unlock up to 100)
- New thread colors
- New Paths (unlock Legend path etc.)
- Fate Archive (read past run stories)

---

## Phase 8: Chronicle System 🔴 Critical (Completed)

**Goal**: Emergent narrative engine (Dwarf Fortress style)

- [x] Entity State & Memory System
- [x] Relationship System (Bonds/Grudges)
- [x] More cards (50+) - (Use `tools/content_generator.gd`)
- [x] More synergies (13+) - (Use `tools/content_generator.gd`)
- [ ] More chapters (5+)
- [ ] More Bids (10+)
- [x] Story Arc Detection
- [x] Chronicle UI Panel
- [x] Persistence (Save/Load)

## Phase 9: Quality of Life 🟡 Medium (Completed)

- [x] Sever Thread Mechanic (Right-click sacrifice)
- [x] Toast Notifications
- [x] Intent Lines (Ghost Threads)

---

## Implementation Order

1. ✅ Phase 3: Card Rarity (foundation)
2. ✅ Phase 1: Multiple Endings (core motivation)
3. ✅ Phase 5: Negative Synergies (strategic depth)
4. ✅ Phase 4: Fate Events (dynamic gameplay)
5. ✅ Phase 2: Hand Management (strategy)
6. ✅ Phase 8: Chronicle System (narrative depth)
7. ✅ Phase 9: Quality of Life (polish)
8. ⏳ Phase 7: Meta-Progression (future)

---

## Estimated Time: Complete
