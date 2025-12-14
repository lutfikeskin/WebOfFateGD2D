# Gameplay Simulation: "Sticky Web" Deadlock Solutions

## Scenario

- Board has 5 slots (Linear: 0-1-2-3-4).
- All 5 slots are filled with **Locked Cards** (previous turns).
- No synergies exist between neighbors (e.g., [Hero] [Dark] [Nature] [Tech] [Void]).
- **Current State:** Player cannot place cards. Game Over (Tangled Web).

## Solution 1: "Sever Thread" (Sacrifice Locked Card)

**Mechanic:** Right-click locked card -> Confirm -> Destroy card (+10 Chaos cost).

- **Turn 1 (Stuck):**
  - Player sees full board.
  - Right-clicks Slot 2 (Nature).
  - Pays 10 Chaos. Card dissolves.
  - Slot 2 is now Empty.
- **Turn 1 (Action):**
  - Player places `Fire_Spell` from hand into Slot 2.
  - Checks synergies: `Fire` + `Tech` (Slot 3) -> Synergy!
  - **Weave Phase:** Slots 2 and 3 clear. Player gains space.
- **Outcome:** Deadlock broken. Cost incurred (risk/reward).
- **Verdict:** **Viable & Thematic.** Adds strategic layer (resource management).

## Solution 2: "Discard from Hand" (Hand Management)

**Mechanic:** Discard a card from hand to draw new ones?

- **Simulation:** If board is full, discarding from hand doesn't help clear the board.
- **Verdict:** **Ineffective** for this specific problem.

## Solution 3: "Board Reset" (Ultimate)

**Mechanic:** "Unravel Fate" button -> Clears entire board (+50 Chaos).

- **Simulation:**
  - Player clicks "Unravel".
  - All 5 cards removed. Chaos +50.
- **Verdict:** **Too drastic.** Removes puzzle element. "Sever Thread" is more granular.

## Solution 4: "Wildcard" (Mechanic)

**Mechanic:** `Fate_Shifter` card that matches ANY tag.

- **Simulation:**
  - Player needs to _draw_ this card.
  - Even if drawn, **cannot place it** because board is full!
- **Verdict:** **Ineffective** if board is already 100% full.

## Solution 5: "Over-write" (New Rule)

**Mechanic:** Allow placing a card on top of a locked card (destroying old one).

- **Simulation:**
  - Player drags `Hero` onto `Villain` (Locked).
  - `Villain` is destroyed. `Hero` is placed.
- **Verdict:** Trivializes "Sticky Web". Removes the punishment/challenge entirely. "Sever Thread" with cost is better balance.

## Conclusion

**"Sever Thread"** is the robust solution. It solves the deadlock, imposes a penalty (maintaining difficulty), and fits the narrative.
