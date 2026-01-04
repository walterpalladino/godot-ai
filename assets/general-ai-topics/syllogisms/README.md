
## Features

**Four Relationship Types:**

-   `is_a` - Inheritance/type relationships (e.g., "Socrates is a human")
-   `has_a` - Possession/composition (e.g., "human has a brain")
-   `is_at` - Location (e.g., "Socrates is at Athens")
-   `comes_from` - Origin (e.g., "Socrates comes from Athens")

**Logical Inference:**

-   **Transitive reasoning**: If A is_a B and B is_a C, then A is_a C
-   **Inheritance**: If A is_a B and B has_a C, then A has_a C
-   **Location chains**: If A is_at B and B is_at C, then A is_at C

**Main Functions:**

-   `add_fact(subject, relation, object)` - Add a new fact to the database
-   `query(subject, relation)` - Get all objects related to a subject by a specific relation
-   `query_all(subject)` - Get all facts about a subject
-   `can_infer(subject, relation, object)` - Check if a fact can be inferred

## Usage

Attach this script to a Node in your Godot scene. It will automatically run an example on start. You can also call the functions directly:

gdscript

```gdscript
add_fact("Plato", "is_a", "philosopher")
add_fact("philosopher", "is_a", "thinker")
var results = query("Plato", "is_a")  # Returns ["philosopher", "thinker"]
```

The system handles both direct facts and logical inferences, making it perfect for knowledge bases, educational games, or AI reasoning systems!

 
