# scenario_manager.gd - Manages scenario database and loading
extends Node

# Dictionary of all scenarios, keyed by ID
var scenarios: Dictionary = {}

func _ready():
	# Initialize scenarios
	_create_example_scenarios()

func _create_example_scenarios():
	# Scenario 1: The Mysterious Box
	var scenario1 = ScenarioData.new()
	scenario1.id = "start"
	scenario1.text = "You enter a dimly lit room. On a wooden table sits a mysterious box, ornately decorated with strange symbols. What do you do?"
	
	var choice1a = ChoiceData.new()
	choice1a.text = "Open the box immediately"
	choice1a.next_scenario = "box_opened"
	var change1 = AttributeChange.new()
	change1.attribute_name = "courage"
	change1.amount = 1
	choice1a.attribute_changes.append(change1)
	
	var choice1b = ChoiceData.new()
	choice1b.text = "Examine the box carefully first"
	choice1b.next_scenario = "box_examined"
	var change2 = AttributeChange.new()
	change2.attribute_name = "wisdom"
	change2.amount = 1
	choice1b.attribute_changes.append(change2)
	
	# Fix: Use append instead of direct assignment
	scenario1.choices.append(choice1a)
	scenario1.choices.append(choice1b)
	
	scenarios[scenario1.id] = scenario1
	
	# Scenario 2: Box Opened
	var scenario2a = ScenarioData.new()
	scenario2a.id = "box_opened"
	scenario2a.text = "With courage, you lift the lid. Inside, you find a mysterious amulet glowing with an otherworldly light. As you reach for it, you hear footsteps approaching..."
	
	var choice2a1 = ChoiceData.new()
	choice2a1.text = "Quickly grab the amulet and hide"
	choice2a1.next_scenario = "guarded_door"
	
	var choice2a2 = ChoiceData.new()
	choice2a2.text = "Leave the amulet and investigate the footsteps"
	choice2a2.next_scenario = "guarded_door"
	var change2a = AttributeChange.new()
	change2a.attribute_name = "wisdom"
	change2a.amount = 1
	choice2a2.attribute_changes.append(change2a)
	
	scenario2a.choices.append(choice2a1)
	scenario2a.choices.append(choice2a2)
	scenarios[scenario2a.id] = scenario2a
	
	# Scenario 3: Box Examined
	var scenario2b = ScenarioData.new()
	scenario2b.id = "box_examined"
	scenario2b.text = "You carefully study the symbols on the box. Your wisdom reveals they're a warning about a curse. With this knowledge, you can safely open it and retrieve the amulet inside."
	
	var choice2b1 = ChoiceData.new()
	choice2b1.text = "Take the amulet and continue"
	choice2b1.next_scenario = "guarded_door"
	
	scenario2b.choices.append(choice2b1)
	scenarios[scenario2b.id] = scenario2b
	
	# Scenario 4: The Guarded Door
	var scenario3 = ScenarioData.new()
	scenario3.id = "guarded_door"
	scenario3.text = "You approach a heavy wooden door. A stern guard stands before it, arms crossed. You need to get through."
	
	var choice3a = ChoiceData.new()
	choice3a.text = "Demand entry with authority"
	choice3a.next_scenario = "confrontation"
	var cond1 = ConditionData.new()
	cond1.condition_type = ConditionData.ConditionType.ATTRIBUTE
	cond1.attribute_name = "courage"
	cond1.comparison = ">="
	cond1.value = 1
	choice3a.conditions.append(cond1)
	
	var choice3b = ChoiceData.new()
	choice3b.text = "Try to sneak past the guard"
	choice3b.next_scenario = "stealth_attempt"
	
	var choice3c = ChoiceData.new()
	choice3c.text = "Use your wisdom to find another way"
	choice3c.next_scenario = "wisdom_path"
	var cond2 = ConditionData.new()
	cond2.condition_type = ConditionData.ConditionType.ATTRIBUTE
	cond2.attribute_name = "wisdom"
	cond2.comparison = ">="
	cond2.value = 2
	choice3c.conditions.append(cond2)
	
	scenario3.choices.append(choice3a)
	scenario3.choices.append(choice3b)
	scenario3.choices.append(choice3c)
	scenarios[scenario3.id] = scenario3
	
	# Scenario 5: Confrontation
	var scenario4 = ScenarioData.new()
	scenario4.id = "confrontation"
	scenario4.text = "You step forward boldly. The guard is impressed by your courage and steps aside, allowing you passage."
	
	var choice4a = ChoiceData.new()
	choice4a.text = "Thank the guard and enter"
	choice4a.next_scenario = "end"
	
	scenario4.choices.append(choice4a)
	scenarios[scenario4.id] = scenario4
	
	# Scenario 6: Stealth Attempt
	var scenario5 = ScenarioData.new()
	scenario5.id = "stealth_attempt"
	scenario5.text = "You wait for the guard to look away, then quietly slip past. Your heart races, but you make it through!"
	
	var choice5a = ChoiceData.new()
	choice5a.text = "Continue forward"
	choice5a.next_scenario = "end"
	
	scenario5.choices.append(choice5a)
	scenarios[scenario5.id] = scenario5
	
	# Scenario 7: Wisdom Path
	var scenario6 = ScenarioData.new()
	scenario6.id = "wisdom_path"
	scenario6.text = "Your wisdom reveals a hidden passage behind a tapestry. You bypass the guard entirely through this secret route."
	
	var choice6a = ChoiceData.new()
	choice6a.text = "Take the secret passage"
	choice6a.next_scenario = "end"
	
	scenario6.choices.append(choice6a)
	scenarios[scenario6.id] = scenario6
	
	# Scenario 8: End
	var scenario7 = ScenarioData.new()
	scenario7.id = "end"
	scenario7.text = "You've completed your journey! Your choices have shaped your character and determined your path through this tale."
	
	var choice7a = ChoiceData.new()
	choice7a.text = "Start over"
	choice7a.next_scenario = "start"
	
	scenario7.choices.append(choice7a)
	scenarios[scenario7.id] = scenario7

func get_scenario(scenario_id: String) -> ScenarioData:
	if scenarios.has(scenario_id):
		return scenarios[scenario_id]
	else:
		push_error("Scenario '%s' not found!" % scenario_id)
		return null

func get_available_choices(scenario: ScenarioData) -> Array[ChoiceData]:
	var available: Array[ChoiceData] = []
	
	for choice in scenario.choices:
		var conditions_met = true
		
		for condition in choice.conditions:
			if not condition.is_met():
				conditions_met = false
				break
		
		if conditions_met:
			available.append(choice)
	
	return available
