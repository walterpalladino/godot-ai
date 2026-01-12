# game_state.gd - Autoload singleton for managing global game state
extends Node

# Player attributes
var attributes: Dictionary = {
	"courage": 0,
	"empathy": 0,
	"strength": 0,
	"intelligence": 0,
	"charisma": 0,
	"wisdom": 0,
	"karma": 0
}

# Story flags for tracking important events
var flags: Dictionary = {}

# Current scenario ID
var current_scenario: String = "start"

# History of visited scenarios (for back-tracking or analytics)
var scenario_history: Array[String] = []

# Save/Load file path
const SAVE_FILE_PATH = "user://game_save.dat"

func _ready():
	load_game()

# Modify an attribute by a given amount
func modify_attribute(attribute_name: String, amount: int) -> void:
	if attributes.has(attribute_name):
		attributes[attribute_name] += amount
		print("Modified %s by %d. New value: %d" % [attribute_name, amount, attributes[attribute_name]])
	else:
		push_error("Attribute '%s' does not exist!" % attribute_name)

# Set a flag to true or false
func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value
	print("Flag '%s' set to %s" % [flag_name, value])

# Check if a flag is set
func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

# Get an attribute value
func get_attribute(attribute_name: String) -> int:
	return attributes.get(attribute_name, 0)

# Check if a condition is met
func check_condition(attribute_name: String, comparison: String, value: int) -> bool:
	var attr_value = get_attribute(attribute_name)
	
	match comparison:
		">=":
			return attr_value >= value
		"<=":
			return attr_value <= value
		">":
			return attr_value > value
		"<":
			return attr_value < value
		"==":
			return attr_value == value
		"!=":
			return attr_value != value
		_:
			push_error("Invalid comparison operator: %s" % comparison)
			return false

# Navigate to a new scenario
func go_to_scenario(scenario_id: String) -> void:
	scenario_history.append(current_scenario)
	current_scenario = scenario_id
	print("Navigating to scenario: %s" % scenario_id)

# Save game state
func save_game() -> void:
	var save_data = {
		"attributes": attributes,
		"flags": flags,
		"current_scenario": current_scenario,
		"scenario_history": scenario_history
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully!")
	else:
		push_error("Failed to save game!")

# Load game state
func load_game() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			attributes = save_data.get("attributes", attributes)
			flags = save_data.get("flags", flags)
			current_scenario = save_data.get("current_scenario", "start")
			scenario_history = save_data.get("scenario_history", [])
			
			print("Game loaded successfully!")
		else:
			push_error("Failed to load game!")
	else:
		print("No save file found. Starting new game.")

# Reset game to initial state
func reset_game() -> void:
	attributes = {
		"courage": 0,
		"empathy": 0,
		"strength": 0,
		"intelligence": 0,
		"charisma": 0,
		"wisdom": 0,
		"karma": 0
	}
	flags.clear()
	current_scenario = "start"
	scenario_history.clear()
	print("Game reset to initial state.")
