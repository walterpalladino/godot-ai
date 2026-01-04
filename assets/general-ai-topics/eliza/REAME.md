## Eliza
Functional ELIZA-style chatbot in GDScript that captures the essence of the classic 1960s conversational AI!

**Key Features:**

**Pattern Matching:**

-   Recognizes keywords like "mother", "father", "feel", "want", "dream"
-   Uses exact and substring pattern matching
-   12+ different pattern categories

**Reflection Technique:**

-   Transforms "I am sad" → "Why do you tell me you're sad?"
-   Converts "I want love" → "Why do you want love?"
-   Switches pronouns naturally (I/you, my/your, etc.)

**Conversation Management:**

-   Tracks conversation history
-   Handles greetings and exits gracefully
-   Falls back to generic responses when no pattern matches

**Example Usage:**

gdscript

```gdscript
# In your game/app:
var eliza = preload("res://eliza.gd").new()

# Get a response
var response = eliza.chat("I'm feeling sad")
# Returns: "Why do you feel that way?"

# View history
print(eliza.get_history())

# Reset conversation
eliza.reset()
```

**Example Conversation:**
```
YOU: I'm feeling sad today
ELIZA: How long have you felt like this?

YOU: My mother never understood me
ELIZA: Tell me more about your family.

YOU: I want to be happy
ELIZA: What would it mean to you if you got to be happy?

YOU: You're not helping
ELIZA: Why do you think I am not helping?
```

The system works just like the original ELIZA - using clever pattern matching and reflection to create the illusion of understanding while actually just reformulating the user's statements as questions!
