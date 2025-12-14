# Feature Proposal: The Weaver's Table

To capture the addictive "Balatro" vibe while leaning into your "Fortune Teller" theme, we need to translate the abstract poker mechanics into thematic narrative elements.

## 1. The Core Loop: "The Hero's Journey"
In Balatro, you beat "Blinds" to progress through "Antes". In Web of Fate, you guide a Hero through **"Ages"** to fulfill **"Prophecies"**.

*   **The Run:** A full life of a Hero (Childhood -> Adulthood -> Legend).
*   **The Round (Age):** A stage of life (e.g., "The reckless youth"). You must reach a specific **Legacy Score** to ensure the hero survives to the next age.
*   **The Boss (Prophecy):** A major destiny event (e.g., "The Great War").
    *   *Condition:* "Must score 10,000 Legacy."
    *   *Debuff:* "All Danger cards give double Chaos." or "Cannot use Mystic cards."

## 2. The Mechanics: "Balatro" Mapping

| Balatro Element | Web of Fate Equivalent | Description |
| :--- | :--- | :--- |
| **Chips** | **Legacy** | The raw impact of an event. |
| **Mult** | **Fate** | The multiplier. Represents destiny amplifying actions. |
| **Jokers** | **Relics / Trinkets** | Physical items on your table (Crystal Ball, Tarot Deck, Incense Burner). They provide passive bonuses (e.g., "+10 Fate for every Danger card"). |
| **Tarot Cards** | **Omens / Runes** | One-time use consumables that modify cards (e.g., "Change a card's tag to 'War'", "Enhance a card to Gold"). |
| **Planet Cards** | **Lessons** | Permanent upgrades to specific "Spreads" (Combos). |
| **Hands** | **Spreads** | The patterns you make on the 2x2 grid. |

## 3. The "Spreads" (Poker Hands)
Instead of just "Combos", let's formalize patterns into "Spreads" that can be leveled up.

*   **The Pair (Row/Col):** Two matching cards horizontally or vertically.
*   **The Cross:** TL matching BR, or TR matching BL.
*   **The Trinity:** 3 cards sharing a tag.
*   **The Convergence (Four of a Kind):** All 4 cards share a tag. *Massive Score.*
*   **The Sequence (Straight):** Cards with sequential IDs or narrative links (Child -> Warrior -> King).
*   **The Conflict:** 2 Danger + 2 Ally. High risk, high reward.

## 4. Progression & Meta-Progression

### Run Progression (Shop)
Between "Ages" (Rounds), the player visits **"The Bazaar"** or **"The Spirit World"**.
*   **Buy Cards:** Add new events to your deck.
*   **Buy Relics:** Buy a "Cursed Ring" (Joker) that gives x3 Mult but +5 Chaos per turn.
*   **Remove Cards:** "Forget" a bad memory (remove a weak card from deck).

### Meta-Progression (Constellations)
Between runs, the player looks up at the **Night Sky**.
*   **Legacy Points** earned in runs become **Starlight**.
*   Spend Starlight to connect stars in **Constellations**.
*   *Unlock:* "Unlock The Warrior Archetype" (Start with a War-heavy deck).
*   *Unlock:* "Unlock The Ruby Lens Relic" (See success chance of cards).

## 5. The "Juice" (Game Feel)
To make it addictive, the presentation must be tactile and magical.

*   **The Table:** It shouldn't just be a UI. It's a wooden table with candles.
    *   *Low Chaos:* Candles burn steadily.
    *   *High Chaos:* Shadows lengthen, whispers become audible, table shakes.
*   **Card Impact:**
    *   When a card resolves, it shouldn't just disappear. It should "burn" into the web.
    *   **High Score:** The thread connecting the cards turns gold/white hot. Sound effects ramp up in pitch.
*   **The "Crunch":**
    *   When the score calculates: `Legacy... *click* ... Fate... *BOOM*`.
    *   Pause for a split second before the big multiplier hits (the "anticipation").

## 6. Content Suggestions (New Cards/Relics)

### Relic Ideas (Jokers)
*   **Hourglass:** x0.5 Mult, but +50 Legacy per turn (Early game carry).
*   **Broken Mirror:** x2 Mult if you play a "Conflict" spread (Danger + Ally).
*   **Blood Pact:** x4 Mult, but Hero takes 1 damage every round.
*   **Weaver's Needle:** +100 Chips for every "Convergence" spread played this run.

### Prophecy Ideas (Bosses)
*   **The Fog:** Cards are played face down (you don't know what they are until resolved).
*   **The Drought:** All "Resource" cards give 0 Legacy.
*   **The Betrayal:** All "Ally" cards are treated as "Danger" cards.

## Implementation Roadmap
1.  **Scoring Overhaul:** Implement `Base * Mult` logic (already planned).
2.  **Spread System:** Formalize "Rows", "Columns", "Crosses" as distinct scoring entities that can be upgraded.
3.  **Relic System:** Create a slot for "Passive Items" that hook into the scoring calculation.
4.  **Shop Phase:** Create a screen between rounds to buy/sell.
