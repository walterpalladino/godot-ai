

## Haiku

**Features:**

-   Generates random haikus following the 5-7-5 syllable pattern
-   Uses word pools organized by syllable count (1, 2, and 3 syllables)
-   Employs different line patterns to create variety
-   Automatically generates a haiku when the node is ready
-   Includes a `get_new_haiku()` method to generate haikus on demand

**How to use:**

1.  Add this script to any Node in your Godot 4 scene
2.  It will automatically print a haiku to the console when the scene runs
3.  Call `get_new_haiku()` to generate additional haikus programmatically

**To expand it:**

-   Add more words to the `words_1_syl`, `words_2_syl`, and `words_3_syl` arrays
-   Create themed word pools (seasons, emotions, nature elements)
-   Add more line patterns for greater variety
-   Connect it to UI elements to display haikus in your game

The generator creates nature-themed haikus with a contemplative tone, staying true to the traditional haiku spirit!

**Themes Available:**

1.  **Nature** - General nature imagery (default)
2.  **Spring** - Awakening, blooms, renewal, new life
3.  **Summer** - Heat, brightness, abundance, lazy days
4.  **Autumn** - Falling leaves, harvest, change, transition
5.  **Winter** - Snow, cold, silence, rest, solitude
6.  **Emotions** - Feelings and inner states (joy, grief, longing, peace)
7.  **Water** - Streams, oceans, rain, flow, reflection
8.  **Sky** - Celestial imagery, clouds, stars, horizons

**How to use:**

gdscript

```gdscript
# Change theme before generating
set_theme("spring")
var haiku = get_new_haiku()

# Or set at the top of the script
current_theme = "emotions"

# Get list of all themes
var themes = get_available_themes()
```

Each theme has 20-30+ words per syllable count, all carefully chosen to match the theme's mood and imagery. You can now create season-specific haikus, emotional introspective pieces, or focus on specific natural elements like water or sky. The themes give your haikus much more cohesive and focused imagery!
