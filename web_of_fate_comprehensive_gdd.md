# Web of Fate - Comprehensive Game Design Document

**Version:** 2.0  
**Last Updated:** 2024  
**Platform:** PC (Godot 4.5)  
**Genre:** Card Game / Puzzle / Narrative / Roguelike Deckbuilder

---

## Table of Contents

1. [Game Overview](#1-game-overview)
2. [Core Gameplay Loop](#2-core-gameplay-loop)
3. [Gameplay Mechanics](#3-gameplay-mechanics)
4. [Progression Systems](#4-progression-systems)
5. [Planned Systems](#5-planned-systems)
6. [Technical Architecture](#6-technical-architecture)
7. [Content Systems](#7-content-systems)
8. [UI/UX Design](#8-uiux-design)
9. [Visual & Audio Polish](#9-visual--audio-polish)
10. [Localization](#10-localization)

---

## 1. Game Overview

### 1.1 Concept

**Web of Fate** is a strategic card game where players weave the threads of destiny by placing cards on a mystical loom. Each card represents characters, items, events, or locations that interact with each other to create synergies, generate Destiny Points (DP), and manage Chaos levels.

### 1.2 Core Pillars

- **Strategic Depth:** Every card placement matters. The "Sticky Web" mechanic means unmatched cards remain on the board, creating tactical decisions.
- **Narrative Integration:** Cards tell stories through synergies and combos, creating emergent narratives.
- **Risk/Reward:** High-power synergies often come with increased Chaos, creating tension between progress and survival.
- **Deckbuilding:** Players customize their deck throughout the run through drafting, card offers, and market purchases.

### 1.3 Target Audience

- Strategy game enthusiasts
- Card game players (Slay the Spire, Balatro, Inscryption fans)
- Story-driven game lovers
- Roguelike enthusiasts

---

## 2. Core Gameplay Loop

### 2.1 Run Structure

#### **Run Start:**

1. **Bid Selection (Path Selection)** - Player chooses one of three paths:

   - Each path has unique objectives (e.g., "Path of Violence", "Path of Harmony", "Path of Chaos")
   - Completing path objectives grants special rewards (relics, modifiers, or cards)
   - Path progress tracks across all chapters in the run

2. **Starting Deck** - Player begins with a predefined deck (typically 20 cards)

#### **Chapter Structure:**

Each chapter consists of:

- **Target DP:** Required Destiny Points to complete
- **Max Chaos:** Chaos limit (exceeding causes game over)
- **Max Turns:** Optional turn limit
- **Starting Deck:** Chapter-specific starting deck (if different from run deck)

### 2.2 Turn-Based Gameplay Loop

```
┌─────────────────────────────────────────────────────────┐
│                    TURN CYCLE                            │
├─────────────────────────────────────────────────────────┤
│ 1. PREPARATION PHASE                                    │
│    - Draw cards up to hand size (5)                     │
│    - Review board state (Sticky Web cards remain)       │
│    - Check resources (DP, Chaos, Fate Threads)          │
│                                                          │
│ 2. PLAYER ACTION PHASE                                  │
│    - Place cards from hand onto 5-slot Loom            │
│    - Cards can be placed in empty slots                 │
│    - Cards placed this turn can be removed              │
│    - Cards from previous turns are locked               │
│    - Visual feedback: Intent lines show connections     │
│                                                          │
│ 3. WEAVING PHASE                                        │
│    - Player clicks "Weave Fate" button                  │
│    - Synergy calculation occurs                         │
│    - Cards with synergies are removed (discarded)       │
│    - Cards without synergies remain (Sticky Web)        │
│    - DP and Chaos are calculated                        │
│    - Passive effects from remaining cards trigger       │
│                                                          │
│ 4. RESOLUTION PHASE                                     │
│    - Visual effects (synergy VFX, screen shake)         │
│    - Narrative logs displayed                           │
│    - Cards locked if they remain on board               │
│    - Turn ends, next turn begins                        │
└─────────────────────────────────────────────────────────┘
```

### 2.3 Chapter Progression Milestones

During a chapter, special events occur at specific turns:

- **Turn 3:** First Card Offer (Remove 1, Add 1)
- **Turn 5:** Market Opens (Purchase Relics/Cards with Fate Threads)
- **Turn 7:** Second Card Offer
- **Turn 10:** Market Opens (if chapter not complete)
- **Chapter Complete:** Draft Phase (Add 1 card to deck)

### 2.4 Chapter Completion Flow

```
Chapter Complete
    ↓
Check Bid Progress
    ↓
Draft Phase (3 cards, choose 1)
    ↓
Next Chapter Load
    ↓
Repeat
```

---

## 3. Gameplay Mechanics

### 3.1 The Loom (Game Board)

#### **Slot System:**

- **5 Slots:** Fixed positions on the board
- **One Card Per Slot:** Only one card can occupy a slot at a time
- **Slot States:**
  - `EMPTY`: Available for placement
  - `OCCUPIED`: Contains a card
  - `LOCKED`: Contains a locked card (from previous turn)

#### **Thread Connections:**

Slots are connected by "Threads" (visual lines) that modify synergies:

| Thread Type | Color    | Effect                  |
| ----------- | -------- | ----------------------- |
| **White**   | Standard | Normal synergy outcomes |
| **Red**     | Violence | DP ×2, Chaos +5         |
| **Gold**    | Sacred   | Chaos -5                |
| **Purple**  | Mystic   | DP +5                   |

**Current Connection Pattern:**

- Slot 0 → Slot 1 (White)
- Slot 1 → Slot 2 (Red)
- Slot 2 → Slot 3 (White)
- Slot 3 → Slot 4 (Gold)

### 3.2 Card System

#### **Card Categories:**

1. **Characters (Actors):** People, creatures, entities
2. **Items (Macguffins):** Weapons, artifacts, objects
3. **Events (Plot Twists):** Story events, disasters
4. **Locations (Context):** Places, settings
5. **Disasters:** Negative events

#### **Card Properties:**

- **ID:** Unique identifier
- **Display Name:** Localized name
- **Description:** Flavor text
- **Category:** Card type
- **Tags:** Array of tags (e.g., `heroic`, `violence`, `romance`)
- **Base DP:** Base Destiny Points value
- **Base Chaos:** Base Chaos value
- **Texture:** Visual representation

#### **Card Interaction Rules:**

- Cards placed in the current turn can be removed and returned to hand
- Cards that remain after "Weave Fate" are locked and cannot be interacted with
- Locked cards can be hovered for information but cannot be clicked or dragged

### 3.3 Synergy System

#### **Synergy Types:**

1. **Specific Combos (Named Synergies):**

   - Predefined card pairs with unique effects
   - Examples:
     - `novice_hero` + `legendary_sword` = "Chosen One" (+50 DP, -10 Chaos)
     - `forbidden_love` + `jealous_prince` = "Romeo & Juliet" (+60 DP, +40 Chaos)
     - `cursed_ring` + `purification_pool` = "Purify Ring" (+80 DP, -10 Chaos)

2. **Tag-Based Synergies:**
   - Any two cards sharing a tag create a generic synergy
   - Base bonus: +10 DP
   - Cards are removed (discarded)
   - Thread type modifies the outcome

#### **Synergy Resolution:**

- Synergies are calculated during the "Weave Fate" phase
- Cards involved in synergies are removed from the board
- DP and Chaos are added to totals
- Narrative log entries are generated

### 3.4 Sticky Web Mechanic

**Core Design Philosophy:** The board is NOT cleared automatically.

- Cards without synergies remain on the board
- These cards occupy slots, limiting future placement options
- Players must strategically plan to "solve" cards by creating synergies
- Creates tactical depth: Do you place a high-value card now, or wait for a synergy partner?

**Locking System:**

- Cards that remain after "Weave Fate" are locked
- Locked cards:
  - Cannot be dragged
  - Cannot be clicked
  - Can be hovered for information
  - May have passive effects (e.g., Cursed Ring: +5 Chaos/turn)

### 3.5 Resource Management

#### **Destiny Points (DP):**

- Primary progression resource
- Generated by:
  - Base card values
  - Synergy bonuses
  - Passive effects
- **Goal:** Reach chapter target DP to complete

#### **Chaos:**

- Risk/Reward resource
- Generated by:
  - Base card values
  - Synergy outcomes
  - Passive effects (e.g., Cursed Ring)
- **Limit:** Exceeding max Chaos causes game over
- **Management:** Some synergies reduce Chaos (Gold threads, specific combos)

#### **Fate Threads (Currency):**

- Earned from synergies (+1 per synergy)
- Used in Market to purchase:
  - Relics (permanent upgrades)
  - Cards (add to deck)
  - Upgrades (temporary bonuses)
- Persists across chapters in a run

### 3.6 Turn Phases

#### **Phase 1: IDLE**

- Initial state, waiting for game start

#### **Phase 2: PLAYER_ACTION**

- Player can place/remove cards
- "Weave Fate" button is enabled
- Hand management

#### **Phase 3: WEAVING**

- Synergy calculation
- Card removal logic
- Resource updates
- Visual effects trigger

#### **Phase 4: RESOLUTION**

- Animations play
- Narrative logs displayed
- Cards locked
- Turn ends

#### **Phase 5: GAME_OVER**

- Game over state
- No further actions possible

---

## 4. Progression Systems

### 4.1 Run Progression

#### **Bid System (Path Selection)**

**Status:** Planned

Players choose one of three paths at run start:

**Example Bids:**

1. **Path of Violence**

   - Objective: Use 15+ cards with `violence` tag
   - Reward: "Bloodthirsty Relic" (Violence synergies +10 DP)

2. **Path of Harmony**

   - Objective: Keep Chaos below 50 for entire run
   - Reward: "Peaceful Aura Relic" (-2 Chaos per turn)

3. **Path of Chaos**
   - Objective: Create 20+ synergies
   - Reward: "Chaos Master Relic" (Synergies give 1.5x DP)

**Implementation:**

- Bid progress tracked across all chapters
- Progress displayed in UI
- Reward granted when objective completed

### 4.2 Chapter Progression

#### **Card Offer System**

**Status:** Planned

**Trigger:** Turns 3, 7, 11 (configurable)

**Mechanic:**

1. Player sees 3 random cards from unlocked pool
2. Player must remove 1 card from current deck
3. Player chooses 1 of the 3 offered cards to add
4. Deck is updated for the run

**Purpose:**

- Allows deck specialization
- Creates strategic decisions (what to remove?)
- Encourages synergy-focused builds

#### **Market System**

**Status:** Planned

**Trigger:** Turns 5, 10 (configurable)

**Mechanic:**

1. Market opens with 3-5 random items
2. Items include:
   - **Relics:** Permanent upgrades (e.g., "+5 DP per synergy")
   - **Cards:** Add to deck
   - **Upgrades:** Temporary bonuses
3. Items cost "Fate Threads" (currency)
4. Player can purchase items or skip

**Currency:**

- **Fate Threads:** Earned from synergies (+1 per synergy)
- Persists across chapters in a run

#### **Draft Phase**

**Status:** Implemented

**Trigger:** Chapter completion

**Mechanic:**

1. Player sees 3 random cards from unlocked pool
2. Player chooses 1 card to add to deck
3. Card is permanently added to run deck
4. Next chapter loads

**Purpose:**

- Deck growth and specialization
- Rewards successful chapter completion

### 4.3 Deck Management

#### **Deck Persistence:**

- Deck persists across chapters in a run
- Cards added through:
  - Draft Phase (chapter completion)
  - Card Offers (mid-chapter)
  - Market purchases
- Cards removed through:
  - Card Offers (forced removal)

#### **Starting Decks:**

- Each chapter can have a unique starting deck
- First chapter uses chapter-specific starting deck
- Subsequent chapters use run deck (persistent)

---

## 5. Planned Systems

### 5.1 Bid System (Path Selection)

**Priority:** High

**Components:**

- `BidData` Resource class
- Bid selection UI (main menu or run start)
- Bid progress tracking in `GameManager`
- Bid completion detection
- Reward system

**BidData Structure:**

```gdscript
class_name BidData extends Resource

@export var bid_name: String
@export_multiline var description: String
@export var target_type: BidTargetType
@export var target_value: int
@export var reward_type: RewardType
@export var reward_data: Dictionary

enum BidTargetType {
    REACH_DP,
    LOW_CHAOS,
    FAST_COMPLETE,
    SYNERGY_COUNT,
    SPECIFIC_TAG
}
```

### 5.2 Card Offer System

**Priority:** High

**Components:**

- `CardOfferManager` Autoload
- Card offer UI (similar to draft panel)
- Deck removal UI
- Turn schedule tracking

**Flow:**

1. Check turn number against schedule
2. Show offer panel
3. Player removes 1 card from deck
4. Player selects 1 of 3 offered cards
5. Update deck

### 5.3 Market System

**Priority:** High

**Components:**

- `MarketData` Resource class
- `RelicData` Resource class
- Market UI
- Currency system (Fate Threads)
- Purchase logic

**RelicData Structure:**

```gdscript
class_name RelicData extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var effect_type: EffectType
@export var effect_value: int

enum EffectType {
    PASSIVE_DP_BONUS,
    CHAOS_REDUCTION,
    HAND_SIZE_INCREASE,
    SYNERGY_MULTIPLIER,
    STARTING_BONUS
}
```

### 5.4 Intent Lines (Ghost Threads)

**Priority:** Medium

**Status:** Partially Implemented

**Feature:**

- When dragging a card over a slot, show semi-transparent lines
- Lines indicate potential connections to other slots
- Visual preview of synergies before placement

**Implementation:**

- Extend `ThreadRenderer` system
- Add hover detection in `GameSlot`
- Calculate potential synergies on hover

### 5.5 Chronicle System (Emergent Narrative Engine)

**Priority:** High

**Status:** ✅ Fully Implemented

The Chronicle System enables Dwarf Fortress-inspired emergent narratives where cards develop personalities, form relationships, and participate in story arcs based on gameplay.

#### **5.5.1 Core Components**

| Resource Class     | Purpose                          | Location                         |
| ------------------ | -------------------------------- | -------------------------------- |
| `EntityState`      | Tracks card memory, mood, titles | `resources/entity_state.gd`      |
| `MemoryEntry`      | Records narrative events         | `resources/memory_entry.gd`      |
| `RelationshipData` | Card-to-card affinity            | `resources/relationship_data.gd` |
| `StoryArc`         | Emergent plot tracking           | `resources/story_arc.gd`         |
| `ChronicleData`    | Master container                 | `resources/chronicle_data.gd`    |
| `ChronicleManager` | Central orchestrator (autoload)  | `logic/chronicle_manager.gd`     |

#### **5.5.2 EntityState - Card Memory**

Each card instance tracks persistent state across the run:

```gdscript
class_name EntityState extends Resource

# Experience
@export var times_played: int = 0
@export var synergies_formed: int = 0
@export var synergy_partners: Array[String] = []
@export var highest_dp_contribution: int = 0
@export var tragic_encounters: int = 0

# Emotional State
@export_range(-1.0, 1.0) var mood: float = 0.0  # -1=despair, 1=exalted
@export var earned_titles: Array[String] = []   # e.g., "the Weaver", "the Legendary"

# Relationships
@export var bonds: Array[String] = []    # Positive affinity cards
@export var grudges: Array[String] = []  # Negative affinity cards
```

**Title System:**
| Title | Requirement |
|-------|-------------|
| "the Weaver" | 10+ synergies formed |
| "the Legendary" | Single synergy ≥80 DP |
| "the Enduring" | Played 15+ times |

#### **5.5.3 MemoryEntry - Event Recording**

Events are recorded as memories with full context:

```gdscript
enum MemoryType {
    SYNERGY_FORMED,     # Two cards formed a synergy
    SYNERGY_FAILED,     # Cards sat together without synergizing
    HIGH_DP_MOMENT,     # DP gained > 50 in single action
    CHAOS_SPIKE,        # Chaos increased > 20 in single action
    SACRIFICE,          # Card removed for strategic benefit
    NEAR_DEATH,         # Chaos came within 10 of max
    CHAPTER_VICTORY,    # Chapter completed successfully
    RUN_ENDED           # Run ended (victory or defeat)
}
```

Factory methods for common events:

- `MemoryEntry.create_synergy_memory(...)`
- `MemoryEntry.create_high_dp_memory(...)`
- `MemoryEntry.create_near_death_memory(...)`

#### **5.5.4 RelationshipData - Card Connections**

Tracks dynamic relationships between card pairs:

```gdscript
@export var affinity: float = 0.0  # -1.0 to 1.0
@export var interaction_count: int = 0
@export var shared_synergies: int = 0
@export var failed_synergies: int = 0
@export var dominant_thread: int = 0  # Most common thread type
@export var history: Array[String] = []  # Narrative fragments
```

**Relationship Status Progression:**
| Affinity Range | Status |
|----------------|--------|
| < -0.5 | Enemies |
| -0.5 to -0.1 | Rivals |
| -0.1 to 0.1 | Strangers |
| 0.1 to 0.4 | Acquaintances |
| 0.4 to 0.7 | Allies |
| > 0.7 | Bonded |

#### **5.5.5 StoryArc - Emergent Plots**

Story arcs are detected and tracked automatically based on card tags and interactions:

```gdscript
enum ArcType {
    HEROIC_JOURNEY,  # Hero rises through trials
    CORRUPTION,      # Good character falls to darkness
    ROMANCE,         # Love story between two cards
    TRAGEDY,         # Inevitable doom narrative
    REVENGE          # Vendetta arc
}

enum ArcPhase {
    INCITING_INCIDENT,
    RISING_ACTION,
    CLIMAX,
    RESOLUTION
}
```

**Arc Trigger Conditions:**

| Arc Type       | Trigger                               | Tags Required       |
| -------------- | ------------------------------------- | ------------------- |
| Heroic Journey | Any synergy involving heroic card     | `heroic`            |
| Romance        | Two romance cards synergize           | `romance` × 2       |
| Corruption     | Heroic meets cursed + violence thread | `heroic` + `cursed` |
| Tragedy        | Tragedy tag + high chaos (≥20)        | `tragedy`           |
| Revenge        | 2+ failed synergies + violence thread | (dynamic)           |

#### **5.5.6 ChronicleManager API**

**Key Methods:**

```gdscript
# Lifecycle
func start_new_chronicle() -> void
func get_or_create_entity(card_id: String) -> EntityState

# Recording Events
func record_synergy(card1_id, card2_id, result, thread_type) -> void
func record_card_played(card_id: String) -> void
func record_synergy_failure(card1_id, card2_id) -> void
func record_near_death(current_chaos, max_chaos) -> void
func record_chapter_complete(dp, chaos, turns) -> void
func record_run_end(is_victory, reason) -> void

# Queries
func get_chronicle_summary() -> String
```

**Signals:**

```gdscript
signal memory_created(memory: MemoryEntry)
signal arc_started(arc: StoryArc)
signal arc_progressed(arc: StoryArc, old_phase: ArcPhase)
signal arc_resolved(arc: StoryArc)
signal entity_title_earned(card_id: String, title: String)
```

#### **5.5.7 Chronicle Panel UI**

The Chronicle Panel displays at level complete/game over:

**Sections:**

1. **Heroes of the Loom** - Notable entities with synergy counts and mood
2. **Bonds Forged** - Strong relationships between cards
3. **Key Moments** - High DP events, near-death experiences, victories
4. **Story Arcs** - Active and completed narrative arcs
5. **Statistics** - Total synergies, turns, peak chaos, etc.

**Location:** `ui/chronicle_panel.gd`, `ui/chronicle_panel.tscn`

#### **5.5.8 Integration Points**

| System                | Integration                                        |
| --------------------- | -------------------------------------------------- |
| `SynergyCalculator`   | Calls `record_synergy()` after each synergy        |
| `GameManager`         | Calls `start_new_chronicle()` on new run           |
| `SaveManager`         | Persists `ChronicleData` with save file            |
| `WebOfFateController` | Shows `ChroniclePanel` on level complete/game over |

#### **5.5.9 Creating Chronicle-Compatible Content**

When adding new cards, use these tags to enable story arcs:

| Tag        | Enables Arc                        |
| ---------- | ---------------------------------- |
| `heroic`   | Heroic Journey                     |
| `romance`  | Romance                            |
| `cursed`   | Corruption (corrupts heroic cards) |
| `tragedy`  | Tragedy (needs chaos ≥20)          |
| `violence` | Amplifies Revenge arc detection    |
| `mystic`   | Narrative flavor                   |
| `hope`     | Positive mood modifiers            |

**Example Card with Tags:**

```gdscript
var knight = CardData.new()
knight.id = "fallen_knight"
knight.tags = ["heroic", "tragedy", "violence"]
knight.base_dp = 15
knight.base_chaos = 10
```

---

## 6. Technical Architecture

### 6.1 Autoload Singletons

#### **GameManager**

**Purpose:** Global game state, progression, level transitions

**Key Responsibilities:**

- Run state management
- Chapter loading
- Deck persistence
- Progress tracking (DP, Chaos, Turns)
- Win/Loss conditions

**Key Variables:**

- `current_state: GameState`
- `current_chapter: ChapterData`
- `player_deck_cards: Array[CardData]`
- `total_dp: int`
- `current_chaos: int`
- `turn_count: int`

#### **TurnManager**

**Purpose:** Turn lifecycle and phase management

**Key Responsibilities:**

- Phase transitions
- Turn counting
- Game over triggering
- Signal emission for phase changes

**Phases:**

- `IDLE`
- `PLAYER_ACTION`
- `WEAVING`
- `RESOLUTION`
- `GAME_OVER`

#### **LoomManager**

**Purpose:** Board state and slot connections

**Key Responsibilities:**

- Slot registration
- Thread connection management
- Card placement tracking
- Connection queries

**Key Data:**

- `_slots: Dictionary` (slot_id → GameSlot)
- `_connections: Array` (connection definitions)

#### **DataManager**

**Purpose:** Resource loading and serving

**Key Responsibilities:**

- Card data loading
- Synergy data loading
- Chapter data loading
- Resource caching

**Key Methods:**

- `get_card_data(id: String) -> CardData`
- `get_all_cards_list() -> Array[CardData]`
- `get_all_synergies() -> Array[SynergyData]`

#### **CardDeckManager**

**Purpose:** Deck operations (draw, discard, shuffle)

**Key Responsibilities:**

- Draw pile management
- Discard pile management
- Card creation from resources
- Shuffling logic

#### **AudioManager**

**Purpose:** Sound effects and music

**Key Responsibilities:**

- SFX playback
- Music playback
- Audio bus management

**Sound Events:**

- `CLICK`, `HOVER`, `CARD_DRAW`, `CARD_PLACE`
- `CARD_DISCARD`, `SYNERGY_FORMED`
- `LEVEL_COMPLETE`, `GAME_OVER`, `CHAOS_WARNING`

#### **SaveManager**

**Purpose:** Save/load game state

**Key Responsibilities:**

- Save game to disk
- Load game from disk
- Save data serialization
- Save data deserialization

**Save Data:**

- Current chapter index
- Player deck (card IDs)
- (Future: Bid progress, Relics, Currency)

#### **NarrativeManager**

**Purpose:** Narrative text generation

**Key Responsibilities:**

- Synergy log generation
- Prophecy generation (planned)
- Story text formatting

#### **TooltipManager**

**Purpose:** Tooltip display management

**Key Responsibilities:**

- Card tooltip display
- Hover detection
- Tooltip positioning

#### **ChronicleManager**

**Purpose:** Emergent narrative system (Chronicle System)

**Status:** ✅ Fully Implemented

**Key Responsibilities:**

- Entity state tracking (card memory, mood, titles)
- Memory recording (synergies, events, victories)
- Relationship management (affinity between cards)
- Story arc detection and progression
- Chronicle summary generation

**Key Variables:**

- `chronicle: ChronicleData` - Master data container

**Key Methods:**

- `start_new_chronicle()` - Reset for new run
- `record_synergy(...)` - Log synergy event
- `record_chapter_complete(...)` - Log chapter victory
- `record_run_end(...)` - Log run completion
- `get_chronicle_summary()` - Generate text summary

**Signals:**

- `memory_created(memory)` - New event recorded
- `arc_started(arc)` - Story arc detected
- `arc_progressed(arc, old_phase)` - Arc advanced
- `entity_title_earned(card_id, title)` - Card earned titletioning

### 6.2 Core Classes

#### **CardData (Resource)**

Card data container:

- ID, name, description
- Category, tags
- Base DP, Base Chaos
- Texture path

#### **SynergyData (Resource)**

Synergy definition:

- Card IDs (pair)
- Result DP, Chaos
- Remove cards flag
- Log message

#### **ChapterData (Resource)**

Chapter configuration:

- Chapter name, description
- Target DP, Max Chaos, Max Turns
- Starting deck

#### **SaveGame (Resource)**

Save data:

- Current chapter index
- Player deck IDs
- (Future: Bid progress, Relics, Currency)

### 6.3 Scene Components

#### **GameTable**

Main gameplay scene:

- Manages 5 game slots
- Handles card placement/removal
- Synergy calculation
- Visual effects
- Resource updates

#### **GameSlot**

Individual slot component:

- Card placement logic
- Highlight states
- Lock/unlock functionality
- Visual feedback

#### **PlayerHand**

Hand management:

- Card arrangement
- Drag and drop
- Hand size management
- Card sorting

#### **WebOfFateController**

Main controller:

- UI management
- Signal connections
- Game flow control
- Panel management

### 6.4 Data-Driven Architecture

**Principle:** All game data is defined in Resource files, not hardcoded.

**Resource Types:**

- `.tres` files for cards, synergies, chapters
- CSV files for translations
- Future: `.tres` files for Bids, Relics, Market items

**Benefits:**

- Easy content creation
- No code changes for new content
- Designer-friendly workflow
- Localization support

---

## 7. Content Systems

### 7.1 Card Database

**Location:** `WebOfFate/data/cards/`

**Structure:**

```
cards/
├── characters/
│   ├── novice_hero.tres
│   ├── bloody_baron.tres
│   └── ...
├── items/
│   ├── legendary_sword.tres
│   ├── cursed_ring.tres
│   └── ...
├── events/
│   ├── sibling_betrayal.tres
│   └── ...
└── locations/
    ├── dark_forest.tres
    └── ...
```

**Card Count:** ~30+ cards (growing)

### 7.2 Synergy Database

**Location:** `WebOfFate/data/synergies/`

**Structure:**

```
synergies/
├── romeo_juliet.tres
├── chosen_one.tres
├── time_travel.tres
└── ...
```

**Synergy Types:**

- Specific combos (named synergies)
- Tag-based (generic synergies)

**Synergy Count:** ~15+ synergies (growing)

### 7.3 Chapter Database

**Location:** `WebOfFate/data/chapters/`

**Chapters:**

1. **Chapter 1: The Awakening**

   - Target DP: 500
   - Max Chaos: 100
   - Max Turns: 10

2. **Chapter 2: Tangled Paths**
   - Target DP: 1000
   - Max Chaos: 80
   - Max Turns: 15

**Future:** More chapters planned

---

## 8. UI/UX Design

### 8.1 Main Menu

**Components:**

- Title
- Play Button
- Continue Button (if save exists)
- How to Play Button
- Language Selection

**States:**

- New game: Continue button hidden
- Save exists: Continue button visible

### 8.2 Gameplay UI

**Components:**

- **Resource Panel:**
  - Destiny Points label
  - Chaos label + progress bar
  - "Weave Fate" button
- **Game Info Panel:**
  - Chapter name
  - Progress (DP / Target DP)
  - Turn count (Turns / Max Turns)
- **Story Panel:**
  - Scrollable narrative log
  - Synergy results
  - Game events
- **Player Hand:**
  - Card display (arc arrangement)
  - Drag and drop
  - Hover tooltips
- **Game Table:**
  - 5 slots with visual feedback
  - Thread connections (visual lines)
  - Card placement zones

### 8.3 Panels

#### **Chapter Start Panel**

- Chapter title
- Narrative intro
- Start button

#### **Level Complete Panel**

- Completion message
- Stats display
- Next Level button

#### **Game Over Panel**

- Game over message
- Reason for failure
- Restart button

#### **Card Reward Panel** (Draft)

- 3 card options
- Card previews
- Select buttons
- Skip option

#### **Card Offer Panel** (Planned)

- 3 card options
- Deck removal interface
- Select/Remove buttons

#### **Market Panel** (Planned)

- Item grid (3-5 items)
- Item previews (Relic/Card)
- Price display (Fate Threads)
- Purchase buttons
- Currency display

### 8.4 Visual Feedback

#### **Slot Highlighting:**

- **Green:** Empty slot, can place
- **Orange:** Slot with removable card (current turn)
- **Red:** Slot with locked card (previous turn)

#### **Intent Lines:**

- Semi-transparent lines when dragging
- Shows potential connections
- Color-coded by thread type

#### **Card States:**

- **Normal:** Interactive, draggable
- **Locked:** Non-interactive, hover-only
- **Selected:** Visual highlight
- **Hovered:** Tooltip display

---

## 9. Visual & Audio Polish

### 9.1 Visual Effects (Juice)

#### **Screen Shake**

**Status:** Implemented

**Triggers:**

- High-impact synergies (DP > 20)
- Game over
- High chaos events

**Implementation:**

- `ScreenShaker` component
- Trauma-based system
- Configurable intensity

#### **Particle Effects**

**Status:** Implemented

**Types:**

- **Synergy VFX:** When synergies form
- **Dissolve VFX:** When cards are discarded
- **Chaos VFX:** When chaos increases significantly

#### **Card Animations**

**Status:** Implemented

**Animations:**

- Card placement (tween)
- Card removal (tween)
- Card discard (dissolve)
- Hand arrangement (arc tween)

### 9.2 Audio System

#### **Sound Effects**

**Status:** Framework Implemented

**Events:**

- Click, Hover
- Card Draw, Card Place, Card Discard
- Synergy Formed
- Level Complete, Game Over
- Chaos Warning

#### **Music**

**Status:** Framework Implemented

**Tracks:**

- Menu theme
- Chapter theme
- Boss theme (future)

**Planned:**

- Dynamic music layers based on Chaos level
- Adaptive music system

### 9.3 Shader Effects

**Status:** Planned

**Planned Effects:**

- Card glow on hover
- Thread pulse animations
- Chaos visual distortion
- Synergy flash effects

---

## 10. Localization

### 10.1 Current Implementation

**Status:** Implemented

**Languages:**

- English (default)
- Turkish

**System:**

- CSV-based translation files
- Godot Translation system
- Dynamic text replacement

**Location:** `WebOfFate/translations/`

**Files:**

- `translations.csv` (source)
- `translations.en.translation` (compiled)
- `translations.tr.translation` (compiled)

### 10.2 Localized Content

**UI Elements:**

- Menu buttons
- Game labels
- Panel text
- Button text

**Dynamic Content:**

- Card names (via `tr()` function)
- Card descriptions
- Synergy log messages
- Chapter names/descriptions

### 10.3 Translation Keys

**Format:** `KEY_NAME`

**Examples:**

- `GAME_TITLE`
- `MENU_PLAY`
- `MENU_CONTINUE`
- `GAME_DP_LABEL`
- `GAME_CHAOS_LABEL`
- `GAME_WEAVE_BTN`

### 10.4 Future Expansion

**Planned:**

- More languages
- Context-aware translations
- Pluralization support
- Date/time formatting

---

## 11. Game Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    RUN START                             │
└─────────────────────────────────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   BID SELECTION (3 Paths)     │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   CHAPTER 1 LOAD              │
        │   - Starting Deck             │
        │   - Chapter Intro             │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURN 1-2: Normal Gameplay   │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURN 3: Card Offer          │
        │   - Remove 1, Add 1            │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURN 4: Normal Gameplay     │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURN 5: Market Opens         │
        │   - Purchase Relics/Cards      │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURN 6-7: Normal Gameplay    │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURN 7: Card Offer          │
        │   - Remove 1, Add 1            │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   TURNS 8-10: Normal Gameplay │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   CHAPTER COMPLETE?            │
        │   - Check DP >= Target        │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   DRAFT PHASE                  │
        │   - 3 Cards, Choose 1          │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   CHECK BID PROGRESS           │
        │   - Update progress            │
        │   - Grant reward if complete   │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   NEXT CHAPTER LOAD            │
        │   - Chapter 2, 3, etc.         │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   REPEAT UNTIL:                │
        │   - All chapters complete      │
        │   - Game Over (Chaos/Turns)    │
        └───────────────────────────────┘
```

---

## 12. Win/Loss Conditions

### 12.1 Win Conditions

**Chapter Complete:**

- `total_dp >= chapter.target_dp`
- Triggers: Draft Phase → Next Chapter

**Run Complete:**

- All chapters completed
- (Future: Victory screen, stats summary)

### 12.2 Loss Conditions

**Chaos Limit:**

- `current_chaos >= chapter.max_chaos`
- Triggers: Game Over

**Turn Limit:**

- `turn_count >= chapter.max_turns` (if max_turns > 0)
- Triggers: Game Over

**Game Over Actions:**

- Save is reset (roguelike style)
- Player returns to main menu
- Can start new run

---

## 13. Future Enhancements

### 13.1 Content Expansion

**Planned:**

- More cards (target: 100+ cards)
- More synergies (target: 50+ synergies)
- More chapters (target: 10+ chapters)
- More Bids (target: 10+ paths)

### 13.2 System Enhancements

**Planned:**

- Relic system (permanent upgrades)
- Market system (purchases)
- Card Offer system (deck management)
- Bid system (path selection)
- Achievement system
- Statistics tracking

### 13.3 Polish

**Planned:**

- Enhanced visual effects
- More particle effects
- Improved animations
- Sound design completion
- Music implementation
- Shader effects

### 13.4 Quality of Life

**Planned:**

- Settings menu (audio, graphics)
- Keybind customization
- Tutorial system
- Help/How to Play screen
- Card collection viewer
- Synergy reference guide

---

## 14. Development Roadmap

### Phase 1: Core Systems (Current)

- ✅ Basic gameplay loop
- ✅ Card system
- ✅ Synergy system
- ✅ Turn management
- ✅ Save/Load
- ✅ Localization

### Phase 2: Progression Systems (Next)

- ⏳ Bid System (Path Selection)
- ⏳ Card Offer System
- ⏳ Market System
- ⏳ Relic System

### Phase 3: Content Expansion

- ⏳ More cards (50+)
- ⏳ More synergies (30+)
- ⏳ More chapters (5+)
- ⏳ More Bids (10+)

### Phase 4: Polish & Enhancement

- ⏳ Enhanced VFX
- ⏳ Complete audio
- ⏳ Shader effects
- ⏳ UI/UX improvements
- ⏳ Tutorial system

---

## 15. Design Principles

### 15.1 Core Principles

1. **Data-Driven:** All content in Resource files
2. **Modular:** Systems communicate via signals
3. **Extensible:** Easy to add new content
4. **Clear Separation:** Logic, Data, Presentation
5. **Player Agency:** Meaningful choices at every step

### 15.2 Code Standards

- **Typed GDScript:** All variables, parameters, returns typed
- **Resource-Based Data:** No hardcoded stats
- **Signal-Based Communication:** No direct scene dependencies
- **Autoload Managers:** Single-responsibility managers
- **Documentation:** Clear comments for complex logic

### 15.3 Content Standards

- **Balanced Synergies:** Risk/Reward considerations
- **Meaningful Choices:** Every decision matters
- **Narrative Integration:** Cards tell stories
- **Progressive Difficulty:** Chapters increase challenge
- **Replayability:** Multiple paths, strategies

---

## Appendix A: Key Terms Glossary

- **DP (Destiny Points):** Primary progression resource
- **Chaos:** Risk resource, exceeding limit causes game over
- **Fate Threads:** Currency earned from synergies
- **Loom:** The game board (5 slots)
- **Sticky Web:** Mechanic where unmatched cards remain on board
- **Synergy:** Card combination that generates DP/Chaos
- **Combo:** Specific named synergy (e.g., "Romeo & Juliet")
- **Thread:** Visual connection between slots, modifies synergies
- **Bid:** Path selection at run start (planned)
- **Relic:** Permanent upgrade (planned)
- **Draft:** Card selection after chapter completion
- **Card Offer:** Mid-chapter deck modification (planned)
- **Market:** Shop for purchasing items (planned)

---

## Appendix B: File Structure

```
WebOfFate/
├── components/
│   ├── game_slot.gd
│   └── thread_renderer.gd
├── data/
│   ├── cards/
│   │   ├── characters/
│   │   ├── items/
│   │   ├── events/
│   │   └── locations/
│   ├── synergies/
│   └── chapters/
├── logic/
│   ├── game_manager.gd
│   ├── turn_manager.gd
│   ├── loom_manager.gd
│   ├── data_manager.gd
│   ├── audio_manager.gd
│   ├── save_manager.gd
│   ├── narrative_manager.gd
│   ├── tooltip_manager.gd
│   └── synergy_calculator.gd
├── resources/
│   ├── card_data.gd
│   ├── synergy_data.gd
│   ├── chapter_data.gd
│   └── save_game.gd
├── ui/
│   ├── card_reward_panel.gd
│   └── (future: market_panel.gd, card_offer_panel.gd)
├── translations/
│   ├── translations.csv
│   ├── translations.en.translation
│   └── translations.tr.translation
├── game_table.gd
├── web_of_fate_controller.gd
└── main_menu.gd
```

---

**Document End**

_This GDD is a living document and will be updated as the game evolves._
