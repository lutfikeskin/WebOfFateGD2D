# Web of Fate (Three.js Prototype) - Implementation Plan

# Goal Description
Create a simplified, playable 3D version of "Web of Fate" using Three.js. The focus is on the core "Draw -> Place -> Resolve" loop with the unique 5-slot cross layout and the Legacy vs. Chaos mechanic.

## User Review Required
> [!NOTE]
> **Scope Reduction:** To ensure a "simpler but playable" version, we are cutting:
> - Complex Path selection (Single endless mode or fixed target initially)
> - Relic System (Can be added later)
> - Complex Card Tags/Combos (Starting with basic Position matches)
> - Save/Load System

## Proposed Changes

### Project Structure
We will use **Vite** with **Vanilla TypeScript** and **Three.js**.

#### [NEW] [Project Setup]
- Initialize Vite project
- Install `three`, `@types/three`, `tween.js` (for animations)
- Setup basic scene (Camera, Lights, Table)

### Core Components

#### [NEW] [Card System](src/logic/Card.ts)
- `Card` class with:
    - `baseChance`: number (0-100)
    - `type`: 'Danger' | 'Safe' | 'Wild'
    - `onResolve()`: Logic for success/fail

#### [NEW] [Game State](src/logic/GameState.ts)
- Manage `Legacy` (Score) and `Chaos` (Health/Mana)
- Manage `Deck` and `Hand`
- Manage `Spread` (The 5 slots)

#### [NEW] [Visuals](src/visuals/)
- `CardMesh.ts`: 3D plane with texture/canvas for card art
- `TableScene.ts`: The 3D world, camera controls
- `WebRenderer.ts`: Procedural lines connecting the slots to visualize the "Web"

### UI Layer (HTML/CSS)
- Minimal HUD for:
    - Current Legacy / Goal
    - Current Chaos
    - "Resolve" Button
    - "Draw" Button

## Verification Plan

### Automated Tests
- Unit tests for `Card` probability logic (optional for prototype, but good practice)

### Manual Verification
- **Gameplay Loop:**
    1. Load page -> See empty table + Hand.
    2. Click Card -> Click Slot -> Card moves to slot.
    3. Fill 5 slots -> Click Resolve.
    4. Watch sequence (TL->TR->BL->BR->Center).
    5. Verify Score/Chaos updates.
    6. Verify "Game Over" if Chaos > Max.
