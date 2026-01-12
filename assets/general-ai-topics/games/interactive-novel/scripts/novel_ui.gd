# novel_ui.gd - Main UI controller for the interactive novel
extends Control

@onready var text_label: Label = $MarginContainer/VBoxContainer/TextLabel
@onready var choices_container: VBoxContainer = $MarginContainer/VBoxContainer/ChoicesContainer
@onready var attributes_label: Label = $MarginContainer/VBoxContainer/AttributesLabel

var current_scenario: ScenarioData

func _ready():
	load_scenario(GameState.current_scenario)
	update_attributes_display()

func load_scenario(scenario_id: String):
	current_scenario = ScenarioManager.get_scenario(scenario_id)
	
	if not current_scenario:
		return
	
	# Set auto-flags for this scenario
	for flag in current_scenario.auto_flags:
		GameState.set_flag(flag)
	
	# Display scenario text
	text_label.text = current_scenario.text
	
	# Clear previous choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Create choice buttons
	var available_choices = ScenarioManager.get_available_choices(current_scenario)
	
	for choice in available_choices:
		var button = Button.new()
		button.text = choice.text
		button.pressed.connect(_on_choice_selected.bind(choice))
		choices_container.add_child(button)

func _on_choice_selected(choice: ChoiceData):
	# Apply attribute changes
	for change in choice.attribute_changes:
		GameState.modify_attribute(change.attribute_name, change.amount)
	
	# Set flags
	for flag in choice.flags_to_set:
		GameState.set_flag(flag)
	
	# Update attributes display
	update_attributes_display()
	
	# Navigate to next scenario
	GameState.go_to_scenario(choice.next_scenario)
	load_scenario(choice.next_scenario)
	
	# Auto-save after each choice
	GameState.save_game()

func update_attributes_display():
	var attr_text = "Attributes:\n"
	for attr_name in GameState.attributes:
		attr_text += "%s: %d\n" % [attr_name.capitalize(), GameState.attributes[attr_name]]
	attributes_label.text = attr_text
