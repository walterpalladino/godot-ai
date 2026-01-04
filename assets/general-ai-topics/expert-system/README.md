
## Key Components:

**1. Item Class**

-   Stores items with flexible attributes in a Dictionary
-   Attributes can be any basic type (int, float, bool, String)
-   Methods to add, check, and retrieve attributes

**2. MatchResult Class**

-   Contains the matched item
-   Tracks which attributes matched
-   Includes a quality score (0.0 to 1.0) representing the percentage of criteria matched
-   Shows match count for easy reference

**3. Expert System Methods**

-   `add_item()` - Add items to the database
-   `find_matches(criteria, require_all)` - Find matching items
	-   Returns items with at least one matching attribute by default
	-   Set `require_all=true` to require all criteria to match
	-   Results sorted by quality (best matches first)
-   `remove_item()`, `get_item()`, `get_all_items()`, `clear_database()` - Database management

## Usage Example:

gdscript

```gdscript
var system = ExpertSystem.new()

# Create an item
var sword = ExpertSystem.Item.new("sword_1", "Magic Sword")
sword.add_attribute("damage", 50)
sword.add_attribute("magical", true)
system.add_item(sword)

# Search for matches
var criteria = {"magical": true, "damage": 50}
var results = system.find_matches(criteria)

for result in results:
	print("Found: %s with quality: %.2f" % [result.item.name, result.quality])
```

The quality score helps you identify the best matches - a score of 1.0 means all criteria matched, while 0.5 means half matched.



## The Prompt

In case could be of use, here is the prompt I used:

*Create a gdscript program that should run on Godot 4 that: works as an expert systems allowing to present a list of options based on attributes included as input. Previously a database is created with items.Those items can or can not include one or more of those attribute so the attributes should be stored on the item as a Dictionary and the attribute itself will be the key and if the item contains that attribute will be the value. That value can be any basic type like int, float, bool or String. So, the program will accept a list of attributes with values and will return a list of items with at least one of the attributes. Should include in the answer a quality value which will represent how many attributes could be matched.*
