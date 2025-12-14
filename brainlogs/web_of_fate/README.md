# Web of Fate - Brainlogs Archive

This directory contains all development session logs related to the **Web of Fate** game project. Each subdirectory represents a single development session with its complete documentation, implementation plans, walkthroughs, and resolved versions.

## Overview

Web of Fate is a strategic card game built with Godot 4.5, featuring:
- **Core Mechanics**: 5-slot Loom system, Synergy-based gameplay, Sticky Web mechanic
- **Narrative System**: Chronicle System with emergent narratives, Story Arcs, Entity States
- **Progression**: Multiple endings, Card rarity system, Path-based progression
- **Localization**: English and Turkish support

## Session Index

### 1. `0ceb0d52-aaf1-4c90-8cb7-3b411866c03a` - Localization (Phase 5)
**Focus**: Turkish translation support implementation

**Key Features**:
- CSV-based translation system
- Language selector in Main Menu
- Translation keys for UI, Paths, Combos, and Relics
- Full Turkish localization

**Files**:
- `task.md` - Localization task checklist
- `implementation_plan.md` - Translation system design
- `walkthrough.md` - Implementation steps

---

### 2. `3bd85da9-37fa-4d42-b6ea-2119c782a814` - Balatro Mechanics & Progression Loop
**Focus**: Game feel, progression systems, and Balatro-inspired mechanics

**Key Features**:
- Visual polish (screen shake, particles, dynamic text)
- Audio system (SFX, Music)
- Meta-progression (Grimoire)
- Shop system
- Content expansion (Combos, Paths, Relics)

**Files**:
- `design_docs/balatro_mechanics.md` - Balatro-inspired design
- `design_docs/progression_loop.md` - Progression system design
- `design_docs/feature_proposal.md` - Feature proposals
- `walkthrough_juice.md` - Game feel implementation
- `walkthrough_scoring.md` - Scoring system

---

### 3. `52be9428-51d4-480d-8777-858b2d4aca66` - Refactor Game Loop & Expand Content
**Focus**: Game loop refactoring and content expansion

**Key Features**:
- Removed Age/Blind system
- Enforced Path system as primary game mode
- Created 10 new Path resources
- Created 50 new Card resources
- Created appropriate Combo resources
- Updated deck size logic (20 cards)

**Files**:
- `task.md` - Refactoring and content tasks
- `implementation_plan.md` - Refactoring strategy
- `walkthrough.md` - Implementation guide

---

### 4. `64f6e2aa-14d2-4d8a-87fa-ac917c94f41d` - Three.js MVP / GDD Review
**Focus**: Three.js prototype and GDD review

**Key Features**:
- Three.js MVP implementation
- 3D visuals (Table, Cards, Web Connections)
- Core logic (Deck, Spread, Resolution)
- GDD review and alignment

**Files**:
- `task.md` - Three.js MVP tasks
- `gdd_review.md` - Game Design Document review
- `implementation_plan.md` - Three.js implementation plan
- `walkthrough.md` - Implementation steps

---

### 5. `742ec640-3608-4c15-b391-7d3ddf0fec88` - Progression Overhaul ⭐
**Focus**: Comprehensive progression system overhaul (Most extensive session)

**Key Features**:
- **Phase 1-5**: Card Rarity System, Multiple Endings (11 endings), Negative Synergies, Fate Events System (10 events)
- **Phase 6-7**: Hand Management (Mulligan), Fate Event UI, Bid/Path System
- **Phase 8**: Arc Progression Feedback (Toast Notifications), Negative Relationship Consequences, Chronicle Save Persistence
- **Phase 9**: Sever Thread (Right-Click Sacrifice)
- **Phase 10**: Outstanding Features (Card Offer System, Market & Economy, Relic System, Meta-Progression, Tutorial)
- **Phase 11**: Path System Expansion (Path-specific Starting Decks)

**Files**:
- `task.md` - Complete progression overhaul checklist (18+ resolved versions)
- `implementation_plan.md` - Detailed implementation plan (5+ resolved versions)
- `walkthrough.md` - Step-by-step implementation guide (3+ resolved versions)
- `simulation_notes.md` - Simulation and testing notes

**Status**: Most comprehensive session with 11 phases of development

---

### 6. `8b3e88b5-58ab-4d83-9a18-07c73a94fd10` - GDD Implementation Summary
**Focus**: Core resource system implementation aligned with GDD

**Key Features**:
- CardData resource implementation
- PathData resource implementation
- CardDB manager
- Center slot integration (5-slot spread)
- Simplified combo system (position-based only)
- Resource system migration from JSON to .tres files

**Files**:
- `implementation_summary.md` - Complete implementation summary
- Sample resource files documentation

---

### 7. `b2052cdb-3afe-4964-9a36-3eabf37065d4` - Modular Game Flow (Balatro-like)
**Focus**: Modular game flow with Balatro-inspired mechanics

**Key Features**:
- 5-slot grid (2x2 + Center)
- Artifacts system (Jokers)
- Shop phase
- Path-based progression
- Diagonal and Cross combo patterns
- State machine (MENU, PLAY, RESOLUTION, SHOP, GAME_OVER)

**Files**:
- `implementation_plan.md` - Modular game flow design
- Artifact system design
- Shop system design

---

### 8. `d03b9311-c214-4108-aa08-74c72268fb60` - Simple Game Scene Creation
**Focus**: Initial simple game scene setup

**Key Features**:
- Simple scene structure (`simple_web_of_fate.tscn`)
- 5-slot layout (TL, TR, BL, BR, Center)
- Manager connections
- Core mechanics verification (Draw -> Place -> Resolve loop)

**Files**:
- `task.md` - Scene creation tasks (10+ resolved versions)
- `implementation_plan.md` - Scene structure design

---

## File Structure

Each session folder typically contains:

- **`task.md`** - Task checklist with checkboxes
- **`implementation_plan.md`** - Detailed implementation plan
- **`walkthrough.md`** - Step-by-step implementation guide
- **`.resolved` files** - Completed versions (numbered: `.resolved.0`, `.resolved.1`, etc.)
- **`.metadata.json`** - Session metadata (timestamps, etc.)
- **Image files** - Screenshots, diagrams (`.png`, `.webp`)
- **Subdirectories** - Additional documentation (e.g., `design_docs/`)

## Key Systems Documented

### Core Gameplay
- 5-slot Loom system
- Synergy calculation
- Sticky Web mechanic
- Turn-based gameplay loop

### Narrative Systems
- Chronicle System (Entity States, Memories, Relationships, Story Arcs)
- Multiple endings (11 types)
- Emergent narrative generation

### Progression Systems
- Card rarity system (Common, Rare, Epic, Legendary)
- Path-based progression
- Hand management (Mulligan)
- Fate Events system

### UI/UX
- Chronicle Panel
- Fate Event Popup
- Hand Selection Panel
- Path Selection Panel
- Toast Notifications

### Technical Architecture
- Resource-based data system (`.tres` files)
- Autoload singletons (GameManager, TurnManager, ChronicleManager, etc.)
- Signal-based communication
- Save/Load system

## Development Timeline

While exact chronological order is difficult to determine from folder names alone, the sessions appear to follow this general progression:

1. **Initial Setup** (`d03b9311-...`) - Simple scene creation
2. **Core Systems** (`8b3e88b5-...`) - GDD implementation, resource system
3. **Game Flow** (`b2052cdb-...`) - Modular game flow, Balatro mechanics
4. **Content Expansion** (`52be9428-...`) - Refactor and content creation
5. **Polish & Feel** (`3bd85da9-...`) - Visual polish, audio, progression
6. **Localization** (`0ceb0d52-...`) - Turkish translation
7. **Progression Overhaul** (`742ec640-...`) - Comprehensive system overhaul
8. **Prototype** (`64f6e2aa-...`) - Three.js MVP exploration

## Notes

- The **Progression Overhaul** session (`742ec640-...`) is the most comprehensive, containing 11 phases of development
- All sessions maintain their original structure and all files are preserved
- Some sessions have multiple resolved versions showing iterative development
- Image files and metadata are preserved in each session folder

## Related Documentation

For the current game state and design, see:
- `web_of_fate_comprehensive_gdd.md` - Complete Game Design Document
- `WebOfFate/` - Current game source code

