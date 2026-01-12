# condition_data.gd - Data structure for conditional checks
class_name ConditionData
extends Resource

enum ConditionType { ATTRIBUTE, FLAG }

@export var condition_type: ConditionType = ConditionType.ATTRIBUTE

# For attribute conditions
@export var attribute_name: String = ""
@export_enum(">=", "<=", ">", "<", "==", "!=") var comparison: String = ">="
@export var value: int = 0

# For flag conditions
@export var flag_name: String = ""
@export var flag_value: bool = true

func is_met() -> bool:
	match condition_type:
		ConditionType.ATTRIBUTE:
			return GameState.check_condition(attribute_name, comparison, value)
		ConditionType.FLAG:
			return GameState.get_flag(flag_name) == flag_value
	return false
