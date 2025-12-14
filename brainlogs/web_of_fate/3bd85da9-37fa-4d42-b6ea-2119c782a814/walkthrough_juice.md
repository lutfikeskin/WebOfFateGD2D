# Visual Juice Walkthrough

I have added a "Juice" layer to the game to make the scoring feel more impactful and satisfying, following SOLID principles by separating visualization from logic.

## Components

### 1. ScoreDisplay (UI View)
-   **Script**: `res://web_of_fate/scripts/ui/ScoreDisplay.gd`
-   **Scene**: `res://web_of_fate/scenes/ui/ScoreDisplay.tscn`
-   **Responsibility**: purely visualizes the score. It has no game logic.
-   **Features**:
    -   **Tweening**: Numbers count up smoothly instead of snapping.
    -   **Pop Animation**: The multiplier "pops" (scales up) when it increases.
    -   **Final Crunch**: A placeholder animation for when the final score is tallied.

### 2. JuiceManager (Controller)
-   **Script**: `res://web_of_fate/scripts/managers/JuiceManager.gd`
-   **Responsibility**: Listens to game events and triggers visual effects. It acts as the bridge between the Logic (`SpreadResolver`) and the View (`ScoreDisplay`, Camera, Particles).
-   **How it works**:
    -   Connects to `SpreadResolver` signals (`event_resolved`, `spread_complete`).
    -   Calls `ScoreDisplay.update_score()`.
    -   Triggers screen shake (implemented via Tween on Camera).

## How to Add More Juice

### Adding Particles
1.  Create a Particle Scene (e.g., `Sparks.tscn`).
2.  Add a `PackedScene` export to `JuiceManager`.
3.  In `JuiceManager._on_event_resolved`, instantiate the particle scene at the card's position.

### Adding Sound
1.  Add an `AudioStreamPlayer` to `JuiceManager` (or a dedicated `AudioManager`).
2.  In `JuiceManager`, play sounds on specific events:
    -   `_on_event_resolved`: Play a "ding" sound (pitch up with each success).
    -   `_on_spread_complete`: Play a "boom" sound if the score is high.

## Scene Integration
The `ScoreDisplay` and `JuiceManager` have been added to `simple_web_of_fate.tscn`.
-   `ScoreDisplay` is located in `Table/Controls`.
-   `JuiceManager` is at the root, with references wired to `ScoreDisplay` and `SpreadResolver`.
