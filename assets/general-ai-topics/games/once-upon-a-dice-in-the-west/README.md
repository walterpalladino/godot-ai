# Once Upon a Dice In The West

# Turn-based Western Game

Turn-based Western game for Godot 4 following the "Once Upon a Dice in The West" rules! Here's what's included:

## **Complete Game Features:**

### **Core Mechanics**

-   ✅ Initiative rolling system (winner chooses to go first)
-   ✅ Character activation with action points (2 per activation)
-   ✅ Natural "1" roll ends turn immediately
-   ✅ Move up to 2D6 inches per turn
-   ✅ Shooting system with range calculations
-   ✅ Wound system (Dazed, Wounded 1-5 times, Killed)
-   ✅ Special characters (Gunfighter, Gunslinger, Leader) with bonuses
-   ✅ Aimed fire (+1 modifier)
-   ✅ On Guard action
-   ✅ Hand-to-hand combat

### **Weapon System**

-   Revolver (6"/12" range)
-   Rifle (12"/24" range)
-   Bow & Arrow (12"/24" range)
-   Spear (6"/12" range)

### **Shooting Modifiers**

-   Target moved: -1
-   Aimed fire: +1
-   Special character shooter: +1
-   Wounded 2+ times: -1
-   Short vs long range hit thresholds


### **🤖 Fully Automated Gameplay**

-   Both players are AI-controlled
-   No UI needed - everything outputs to console
-   Automated decision-making for all actions
-   Self-playing battle simulation

### **📊 Console Output Features**

-   Detailed game setup with character rosters
-   Initiative rolls each round
-   Character activation announcements
-   Action descriptions with dice rolls
-   Combat results with modifiers shown
-   Wound tracking and status updates
-   Round summaries
-   Victory announcements

### **🎮 AI Decision Making**

The AI automatically:

-   Selects characters to activate
-   Chooses optimal actions based on situation:
	-   **Melee** if within 1" of enemy
    -   **Aim + Shoot** if in range with 2 AP
    -   **Shoot** if in range
    -   **Move** toward closest enemy if out of range
-   Handles all dice rolls and modifiers
-   Follows all game rules