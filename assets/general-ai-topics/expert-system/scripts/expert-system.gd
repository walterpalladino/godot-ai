extends Node

## Expert System for attribute-based item matching
## Stores items with flexible attributes and finds matches based on criteria

class_name ExpertSystem

# Item structure with attributes and metadata
class Item:
	var id: String
	var name: String
	var attributes: Dictionary = {}
	
	func _init(p_id: String, p_name: String, p_attributes: Dictionary = {}):
		id = p_id
		name = p_name
		attributes = p_attributes.duplicate()
	
	func add_attribute(key: String, value) -> void:
		attributes[key] = value
	
	func has_attribute(key: String) -> bool:
		return attributes.has(key)
	
	func get_attribute(key: String):
		return attributes.get(key, null)
	
	func as_string() -> String:
		return "Item(%s, %s, %s)" % [id, name, str(attributes)]

# Result structure with quality score
class MatchResult:
	var item: Item
	var matched_attributes: Dictionary = {}
	var quality: float = 0.0
	var match_count: int = 0
	
	func _init(p_item: Item):
		item = p_item
	
	func as_string() -> String:
		return "Match(item=%s, quality=%.2f, matches=%d, attrs=%s)" % [
			item.name, quality, match_count, str(matched_attributes)
		]

# Database storage
var items: Dictionary = {}

## Add an item to the database
func add_item(item: Item) -> void:
	items[item.id] = item
	print("Added item: ", item.as_string())

## Remove an item from the database
func remove_item(item_id: String) -> bool:
	if items.has(item_id):
		items.erase(item_id)
		print("Removed item: ", item_id)
		return true
	return false

## Get an item by ID
func get_item(item_id: String) -> Item:
	return items.get(item_id, null)

## Get all items
func get_all_items() -> Array[Item]:
	var result: Array[Item] = []
	for item in items.values():
		result.append(item)
	return result

## Clear the entire database
func clear_database() -> void:
	items.clear()
	print("Database cleared")

## Find items matching the given criteria
## @param criteria: Dictionary of attribute keys and desired values
## @param require_all: If true, only return items matching ALL criteria
## @return Array of MatchResult objects sorted by quality (descending)
func find_matches(criteria: Dictionary, require_all: bool = false) -> Array[MatchResult]:
	var results: Array[MatchResult] = []
	
	if criteria.is_empty():
		print("Warning: Empty criteria provided")
		return results
	
	var total_criteria = criteria.size()
	
	for item in items.values():
		var result = MatchResult.new(item)
		
		for key in criteria.keys():
			if item.has_attribute(key):
				var item_value = item.get_attribute(key)
				var criteria_value = criteria[key]
				
				# Check if values match
				if _values_match(item_value, criteria_value):
					result.matched_attributes[key] = item_value
					result.match_count += 1
		
		# Calculate quality score (percentage of matched attributes)
		result.quality = float(result.match_count) / float(total_criteria)
		
		# Add to results if criteria met
		if require_all:
			if result.match_count == total_criteria:
				results.append(result)
		else:
			if result.match_count > 0:
				results.append(result)
	
	# Sort by quality (descending)
	results.sort_custom(func(a, b): return a.quality > b.quality)
	
	return results

## Compare two values for matching
func _values_match(item_value, criteria_value) -> bool:
	# Handle different types
	if typeof(item_value) != typeof(criteria_value):
		# Try string comparison as fallback
		return str(item_value) == str(criteria_value)
	
	match typeof(item_value):
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return item_value == criteria_value
		TYPE_STRING_NAME:
			return str(item_value) == str(criteria_value)
		_:
			return item_value == criteria_value

## Print all items in the database
func print_database() -> void:
	print("\n=== Database Contents ===")
	if items.is_empty():
		print("(empty)")
	else:
		for item in items.values():
			print(item.as_string())
	print("========================\n")

## Print match results
func print_results(results: Array[MatchResult]) -> void:
	print("\n=== Match Results ===")
	if results.is_empty():
		print("No matches found")
	else:
		print("Found %d matches:" % results.size())
		for i in range(results.size()):
			var r = results[i]
			print("  %d. %s" % [i + 1, r.as_string()])
	print("=====================\n")


# ============================================
# EXAMPLE USAGE (for testing in _ready)
# ============================================

func _ready():
	print("Expert System initialized\n")
	
	# Example: Create a database of fantasy weapons
	var sword = Item.new("sword_001", "Steel Sword")
	sword.add_attribute("damage", 25)
	sword.add_attribute("weight", 3.5)
	sword.add_attribute("material", "steel")
	sword.add_attribute("two_handed", false)
	sword.add_attribute("magical", false)
	add_item(sword)
	
	var axe = Item.new("axe_001", "Battle Axe")
	axe.add_attribute("damage", 35)
	axe.add_attribute("weight", 5.0)
	axe.add_attribute("material", "iron")
	axe.add_attribute("two_handed", true)
	axe.add_attribute("magical", false)
	add_item(axe)
	
	var staff = Item.new("staff_001", "Wizard Staff")
	staff.add_attribute("damage", 15)
	staff.add_attribute("weight", 2.0)
	staff.add_attribute("material", "wood")
	staff.add_attribute("two_handed", true)
	staff.add_attribute("magical", true)
	staff.add_attribute("mana_bonus", 50)
	add_item(staff)
	
	var dagger = Item.new("dagger_001", "Silver Dagger")
	dagger.add_attribute("damage", 18)
	dagger.add_attribute("weight", 1.0)
	dagger.add_attribute("material", "silver")
	dagger.add_attribute("two_handed", false)
	dagger.add_attribute("magical", true)
	add_item(dagger)
	
	print_database()
	
	# Example query 1: Find two-handed magical weapons
	print("Query 1: Find two-handed magical weapons")
	var criteria1 = {
		"two_handed": true,
		"magical": true
	}
	var results1 = find_matches(criteria1)
	print_results(results1)
	
	# Example query 2: Find light weapons (under 2.5 weight)
	print("Query 2: Find weapons under 2.5 weight with high damage")
	var criteria2 = {
		"weight": 2.0,  # Will match exact value
		"magical": true
	}
	var results2 = find_matches(criteria2)
	print_results(results2)
	
	# Example query 3: Find any steel or silver weapons
	print("Query 3: Find silver material weapons")
	var criteria3 = {
		"material": "silver"
	}
	var results3 = find_matches(criteria3)
	print_results(results3)
