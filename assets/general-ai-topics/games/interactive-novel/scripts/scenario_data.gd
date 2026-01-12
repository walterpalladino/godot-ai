# scenario_data.gd - Data structure for scenarios
class_name ScenarioData
extends Resource

# The unique ID for this scenario
@export var id: String = ""

# The narrative text to display
@export_multiline var text: String = ""

# Available choices in this scenario
@export var choices: Array[ChoiceData] = []

# Conditions that must be met to access this scenario
@export var conditions: Array[ConditionData] = []

# Automatically set flags when entering this scenario
@export var auto_flags: PackedStringArray = []
