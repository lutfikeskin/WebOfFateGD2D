# Web of Fate - Card & Synergy Database

This document provides a comprehensive table of all cards, their base stats, tags, and known synergies/combos implemented in the game.

## 1. Card Database

### Category 1: Characters (Actors)
| ID | Name | Tags | Base DP | Base Chaos | Special Notes |
|---|---|---|---|---|---|
| `novice_hero` | Novice Hero | `heroic` | 5 | 2 | - |
| `forbidden_love` | Forbidden Love | `romance`, `tragedy` | 20 | 10 | - |
| `bloody_baron` | Bloody Baron | `violence`, `villain` | 15 | 15 | - |
| `mystic_guide` | Mystic Guide | `mystic`, `support` | 10 | 0 | - |
| `court_jester` | Court Jester | `chaos` | 0 | 0 | - |
| `plague_rat` | Plague Rat | `disease` | 0 | 5 | - |
| `dragon_whelp` | Dragon Whelp | `monster`, `dragon` | 30 | 20 | - |
| `shadow_assassin` | Shadow Assassin | `killer`, `shadow` | 0 | 0 | - |
| `jealous_prince` | Jealous Prince | `royalty`, `villain` | 15 | 10 | - |
| `tyrant_king` | Tyrant King | `royalty`, `villain` | 25 | 25 | - |
| `blacksmith` | Blacksmith | `support`, `craftsman` | 10 | 0 | - |

### Category 2: Items (Macguffins)
| ID | Name | Tags | Base DP | Base Chaos | Special Notes |
|---|---|---|---|---|---|
| `legendary_sword` | Legendary Sword | `weapon`, `metal` | 20 | 5 | - |
| `cursed_ring` | Cursed Ring | `mystic`, `cursed` | 40 | 0 | +5 Chaos/turn (Passive) |
| `grandmas_cookie` | Grandma's Cookie | `food`, `comfort` | 0 | -20 | - |
| `map_fragment` | Map Fragment | `quest`, `mystery` | 5 | 0 | - |
| `poisoned_chalice` | Poisoned Chalice | `poison`, `assassination` | 10 | 10 | - |
| `puppet_strings` | Puppet Strings | `manipulation` | 0 | 0 | - |
| `broken_shield` | Broken Shield | `defense`, `metal` | 0 | -10 | - |

### Category 3: Events (Plot Twists)
| ID | Name | Tags | Base DP | Base Chaos | Special Notes |
|---|---|---|---|---|---|
| `sibling_betrayal` | Sibling Betrayal | `tragedy`, `betrayal` | 50 | 40 | - |
| `sudden_storm` | Sudden Storm | `nature`, `disaster_mitigation` | 0 | 0 | - |
| `heroic_sacrifice` | Heroic Sacrifice | `heroic`, `death` | 0 | 0 | Sets Chaos to 0 |
| `misunderstanding` | Misunderstanding | `comedy`, `conflict` | 0 | 10 | - |
| `prophecy` | Prophecy | `mystic`, `info` | 0 | 0 | - |
| `dawn_break` | Dawn Break | `light`, `hope` | 0 | -15 | - |
| `wedding_ceremony` | Wedding Ceremony | `romance`, `celebration` | 10 | -5 | - |
| `volcano_eruption` | Volcano Eruption | `disaster`, `fire` | 40 | 30 | - |

### Category 4: Locations (Context)
| ID | Name | Tags | Base DP | Base Chaos | Special Notes |
|---|---|---|---|---|---|
| `dark_forest` | Dark Forest | `nature`, `dark` | 0 | 0 | - |
| `ruined_shrine` | Ruined Shrine | `holy`, `ruin` | 0 | 0 | - |
| `tavern_corner` | Tavern Corner | `social`, `safe` | 0 | -15 | - |
| `cliff_edge` | Cliff Edge | `nature`, `danger` | 0 | 10 | - |
| `marketplace` | Marketplace | `social`, `trade` | 0 | 0 | - |
| `volcano` | Volcano | `nature`, `fire` | 10 | 10 | +10 Chaos/turn (Passive) |
| `purification_pool` | Purification Pool | `holy`, `water` | 0 | 0 | - |
| `time_gate` | Time Gate | `mystic`, `time` | 20 | 0 | - |

### Category 5: Disasters (Chaos Boosters)
| ID | Name | Tags | Base DP | Base Chaos | Special Notes |
|---|---|---|---|---|---|
| `crimson_moon` | Crimson Moon | `celestial`, `chaos_boost` | 0 | 0 | Multiplies violence chaos |
| `oblivion` | Oblivion | `void` | 0 | 0 | - |
| `time_paradox` | Time Paradox | `time`, `chaos` | 0 | 50 | - |
| `mass_hysteria` | Mass Hysteria | `social`, `panic` | 0 | 0 | +5 Chaos per Character |
| `wrath_of_god` | Wrath of God | `divine`, `endgame` | 0 | 100 | - |
| `doomsday_clock` | Doomsday Clock | `time`, `doom` | 0 | 0 | - |

---

## 2. Synergies & Combos

### Specific Named Combos
These interactions trigger special logs and high rewards when connected.

| Name | Card 1 | Card 2 | Result DP | Result Chaos | Effect |
|---|---|---|---|---|---|
| **Romeo & Juliet** | `forbidden_love` | `jealous_prince` | +60 | +40 | Tragic tale unfolds. |
| **Chosen One** | `novice_hero` | `legendary_sword` | +50 | -10 | A hero is born! |
| **Ancient Dragon** | `dragon_whelp` | `volcano` | +100 | +50 | Dragon grows ancient. |
| **Purify Ring** | `cursed_ring` | `purification_pool` | +80 | -10 | Ring cleansed. |
| **Destroy Ring** | `cursed_ring` | `volcano` | +80 | -10 | Ring destroyed in fire. |
| **Treasure Room** | `map_fragment` | `map_fragment` | +50 | 0 | Map complete! |
| **Tyrant's Oppression** | `tyrant_king` | `bloody_baron` | +80 | +40 | Oppress the land. |
| **Silent Death** | `shadow_assassin` | `poisoned_chalice` | +60 | -10 | A silent end. |
| **Repair Shield** | `blacksmith` | `broken_shield` | +40 | -20 | Defense restored. |
| **Plague Outbreak** | `plague_rat` | `marketplace` | +20 | +60 | Chaos spreads! |
| **Comedy of Errors** | `court_jester` | `misunderstanding` | +50 | +20 | Hilarious disaster. |
| **Time Travel** | `mystic_guide` | `time_gate` | +100 | 0 | Secrets revealed. |

### General Tag Synergies
Any two cards sharing a tag will trigger a basic synergy.

| Shared Tag | Base Bonus | Special Effects |
|---|---|---|
| **Any Matching Tag** | +10 DP | Cards are removed (Discarded). |

### Thread Type Modifiers
The visual thread connecting the slots modifies the outcome.

| Thread Color | Type | Effect |
|---|---|---|
| **White** | Normal | Standard outcome. |
| **Red** | Violence | **DP x2**, **Chaos +5**. High risk, high reward. |
| **Gold** | Sacred | **Chaos -5**. Reduces chaos accumulation. |
| **Purple** | Mystic | **DP +5**. Slight magic boost. |

---

## 3. Passive Effects
Some cards have effects just by remaining on the board (Sticky Web).

*   **Cursed Ring:** +5 Chaos per turn.
*   **Volcano:** +10 Chaos, +10 DP per turn.
