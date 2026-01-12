
# Interactive Novel

**Setup Instructions:**

1.  **Create an Autoload**: Add `game_state.gd` as an autoload singleton named "GameState"
2.  **Create an Autoload**: Add `scenario_manager.gd` as an autoload singleton named "ScenarioManager"
3.  **Create the Resource scripts**: Save the data classes (`ScenarioData`, `ChoiceData`, `AttributeChange`, `ConditionData`) as separate files
4.  **Create the UI scene**: Build a scene with the structure expected by `novel_ui.gd`
5.  **Customize scenarios**: Modify `_create_example_scenarios()` or create scenarios via the editor

This system provides a complete foundation for an interactive novel with persistent attributes, conditional branching, and save/load functionality!


## Test Scene

Here's a detailed guide to building the UI scene for the interactive novel:

## Scene Structure Setup

### Step 1: Create the Main Scene

1.  In Godot, create a new scene
2.  Select **Control** as the root node
3.  Rename it to `NovelUI`
4.  Attach the `novel_ui.gd` script to this root node

### Step 2: Configure the Root Node

-   Select the `NovelUI` node
-   In the Inspector, under **Layout**:
    -   Set **Anchors Preset** to "Full Rect" (the icon that fills the entire screen)
    -   This makes the UI fill the entire game window

### Step 3: Add MarginContainer

1.  Right-click `NovelUI` → Add Child Node → Search for **MarginContainer**
2.  With MarginContainer selected:
    -   Set **Anchors Preset** to "Full Rect"
    -   In the Inspector, set **Theme Overrides > Constants**:
        -   Margin Left: `40`
        -   Margin Top: `40`
        -   Margin Right: `40`
        -   Margin Bottom: `40`
    -   This creates padding around the edges of the screen

### Step 4: Add VBoxContainer

1.  Right-click `MarginContainer` → Add Child Node → **VBoxContainer**
2.  With VBoxContainer selected:
    -   Set **Anchors Preset** to "Full Rect"
    -   In the Inspector, under **Theme Overrides > Constants**:
        -   Separation: `20` (space between elements)

### Step 5: Add the Text Label (Story Text)

1.  Right-click `VBoxContainer` → Add Child Node → **Label**
2.  Rename it to `TextLabel`
3.  Configure TextLabel:
    -   In the Inspector, under **Control > Layout**:
        -   Set **Size Flags > Vertical** to "Expand"
    -   Under **Label**:
        -   Set **Text** to a placeholder like "Story text will appear here..."
        -   Enable **Autowrap Mode** → "Word (Smart)"
        -   Set **Vertical Alignment** to "Top"
    -   Under **Theme Overrides > Font Sizes**:
        -   Font Size: `18` (or your preference)

### Step 6: Add the Choices Container

1.  Right-click `VBoxContainer` → Add Child Node → **VBoxContainer**
2.  Rename it to `ChoicesContainer`
3.  Configure ChoicesContainer:
    -   Under **Theme Overrides > Constants**:
        -   Separation: `10` (space between choice buttons)
    -   Under **Control > Layout**:
        -   Set **Size Flags > Vertical** to "Shrink End"
        -   This keeps choices at the bottom

### Step 7: Add the Attributes Label

1.  Right-click `VBoxContainer` → Add Child Node → **Label**
2.  Rename it to `AttributesLabel`
3.  Configure AttributesLabel:
    -   Set **Text** to a placeholder like "Attributes will appear here..."
    -   Enable **Autowrap Mode** → "Word"
    -   Under **Theme Overrides > Font Sizes**:
        -   Font Size: `14`
    -   Under **Theme Overrides > Colors**:
        -   Font Color: Choose a subtle color (e.g., light gray)

## Final Scene Hierarchy

Your scene tree should look like this:

```
NovelUI (Control) [novel_ui.gd attached]
└── MarginContainer
    └── VBoxContainer
        ├── TextLabel (Label)
        ├── ChoicesContainer (VBoxContainer)
        └── AttributesLabel (Label)
```

## Visual Polish (Optional)

### Add a Background Panel

1.  Right-click `NovelUI` → Add Child Node → **Panel**
2.  Move it to be the **first child** (above MarginContainer)
3.  Set **Anchors Preset** to "Full Rect"
4.  In the Inspector:
    -   Under **Theme Overrides > Styles**:
        -   Create a new **StyleBoxFlat**
        -   Set **Bg Color** to a dark color (e.g., `#1a1a1a`)

### Style the Choice Buttons (Optional)

Since buttons are created dynamically, you can style them in the script. Modify the `load_scenario` function in `novel_ui.gd`:

gdscript

```gdscript
func load_scenario(scenario_id: String):
	# ... existing code ...
	
	for choice in available_choices:
		var button = Button.new()
		button.text = choice.text
		button.custom_minimum_size = Vector2(0, 50)  # Minimum height
		
		# Optional: Add custom styling
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.3, 0.4)
		style.corner_radius_top_left = 5
		style.corner_radius_top_right = 5
		style.corner_radius_bottom_left = 5
		style.corner_radius_bottom_right = 5
		button.add_theme_stylebox_override("normal", style)
		
		button.pressed.connect(_on_choice_selected.bind(choice))
		choices_container.add_child(button)
```

## Testing the Scene

1.  Save the scene as `novel_ui.tscn`
2.  Set it as the main scene (F6 or Run Project)
3.  You should see:
    -   The scenario text at the top
    -   Available choice buttons in the middle
    -   Current attributes displayed at the bottom

## Troubleshooting

If nodes aren't showing up:

-   Check that `@onready` variable names in `novel_ui.gd` match your node names **exactly**
-   Verify the node paths: Use the "Copy Node Path" feature and compare to the script
-   Ensure all nodes are children of the correct parents

If text is cut off:

-   Enable **Autowrap Mode** on Label nodes
-   Check that VBoxContainer has **Size Flags > Vertical** set to "Expand" for TextLabel

That's it! You now have a functional interactive novel UI ready to display your scenarios and choices.



## Prompt used

Write for Godot 4 using gdscript the logic for:

A game system for an interactive novel where choices affect persistent attributes relies on a core logic of state management and conditional branching. This logic uses variables (attributes) to track the player's progress and influence subsequent events and dialogue options. Core System Logic The system operates in a continuous loop:

1.  Present Scenario: The game displays a block of text describing the current situation and the available options.
2.  Player Choice: The player selects an option.
3.  Attribute Modification (Logic): The chosen option triggers a pre-defined change in one or more character attributes. This is the central logic gate of the system.
	-   Example: Option A adds +1 to 'Courage'. Option B adds +1 to 'Empathy'.
4.  State Update: The game saves the modified attributes to the player's persistent profile (the "game state").
5.  Next Interaction (Conditional Branching): The system uses the updated attributes to determine which scenario to load next.
	-   Example: If 'Courage' is >= 3, load scenario X (e.g., the character stands up to a bully). If 'Courage' is < 3, load scenario Y (e.g., the character walks away). Game Components This system uses several key components to manage the logic:

-   Attributes (Variables): Numerical or Boolean values that track character traits (e.g., Strength, Charisma, Sanity, Trustworthiness). These values persist throughout the game.
-   Choices & Outcomes: Each choice has a defined outcome:
    -   It advances the story to a specific new node.
    -   It modifies one or more attributes (e.g., `Intelligence + 1`, `Karma - 2`).
-   Conditional Gates: These are checks performed by the game logic before presenting a new interaction. They verify if specific conditions are met before allowing access to certain dialogue, actions, or entire story branches.
    -   Example: "Is `Strength` greater than 5?" determines if the player can lift a heavy object.
-   Flags: Specific Boolean variables that mark if an important event has occurred.
    -   Example: A `HasVisitedTheCave` flag might be set to `True` after an early chapter and checked much later to unlock a secret dialogue option. Flow of Logic Example Here is a simplified flowchart of the logic in action:

1.  Start: Attributes initialized: `(Bravery: 0, Wisdom: 0)`
2.  Scenario 1: A mysterious box is on the table.
    -   Option A: Open the box. Logic: `Bravery + 1`
    -   Option B: Examine the box first. Logic: `Wisdom + 1`
3.  Scenario 2 (Conditional Gate): A guard blocks the door.
    -   Logic Check: Is `Bravery` >= 1?
    -   If Yes: Present option to "Demand entry" (leads to a confrontation scene).
    -   If No: Present option to "Try to sneak past" (leads to a stealth scene). This logic ensures that every decision the player makes has a lasting impact on how the story unfolds, creating a personalized and dynamic narrative experience.
	
