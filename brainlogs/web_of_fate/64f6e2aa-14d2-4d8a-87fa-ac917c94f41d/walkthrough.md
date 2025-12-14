# Web of Fate - Prototype Walkthrough

**Version:** 0.1.0 (Three.js Prototype)  
**Status:** Playable MVP

---

## Overview
This prototype implements the core "Draw -> Place -> Resolve" loop of *Web of Fate* using Three.js. It features a 3D table, card manipulation, and the unique 5-slot spread mechanic.

## Features Implemented
- **3D Environment:** A table with 5 slots (Cross layout) and dynamic lighting.
- **Card System:** 
    - **Safe Cards:** High chance, low reward.
    - **Danger Cards:** Low chance, high reward.
    - **Wild Cards:** Balanced stats.
- **Web Visualization:** Glowing lines connect the slots, intensifying when cards are placed.
- **Core Loop:**
    1. **Draw:** Get 8 cards.
    2. **Place:** Click a card in hand, then click a slot (or click a placed card to return it).
    3. **Resolve:** Click "RESOLVE FATE" to trigger the sequence (TL->TR->BL->BR->Center).
    4. **Score:** Watch Legacy (Score) go up and Chaos (Risk) accumulate.

## How to Play
1. **Start:** Open the game in your browser (Localhost).
2. **Draw:** Click "Draw Hand" if your hand is empty.
3. **Place:** 
    - Click a card in your hand (it highlights).
    - Click a slot on the table (the ring markers).
    - *Tip:* Try to place High-Risk cards *after* Safe cards to build Momentum (though Momentum logic is hidden in this prototype).
4. **Resolve:** Once you're happy with the spread (you don't need to fill all slots), click "RESOLVE FATE".
5. **Survive:** Keep your Chaos below 300!

## Technical Notes
- **Engine:** Vite + Three.js + Vanilla TypeScript.
- **Architecture:**
    - `GameState`: Manages logic (Deck, Hand, Spread).
    - `TableScene`: Manages 3D rendering and input.
    - `WebRenderer`: Procedural line generation.
- **Extensibility:** New cards can be added in `GameState.ts` without touching the visuals.

## Next Steps
- Add visual feedback for Success/Failure (Green/Red flashes).
- Implement the "Path" system (Win conditions).
- Add "Relics" for passive bonuses.
