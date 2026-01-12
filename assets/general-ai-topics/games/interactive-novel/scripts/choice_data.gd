# choice_data.gd - Data structure for choices
class_name ChoiceData
extends Resource

# The text displayed for this choice
@export var text: String = ""

# The scenario to navigate to after choosing this
@export var next_scenario: String = ""

# Attribute modifications when this choice is selected
@export var attribute_changes: Array[AttributeChange] = []

# Flags to set when this choice is selected
@export var flags_to_set: PackedStringArray = []

# Conditions that must be met for this choice to appear
@export var conditions: Array[ConditionData] = []
