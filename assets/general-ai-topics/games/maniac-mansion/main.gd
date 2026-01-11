extends Control

# Test Runner for Maniac Mansion Text Adventure
# Save this as main.gd and attach to a Control node

@onready var output_label : Label = $VBoxContainer/ScrollContainer/OutputLabel
@onready var input_field : LineEdit = $VBoxContainer/HBoxContainer/InputField
@onready var submit_button : Button = $VBoxContainer/HBoxContainer/SubmitButton
@onready var scroll_container : ScrollContainer = $VBoxContainer/ScrollContainer

var game: ManiacMansionGame
var output_history: String = ""

func _ready():
	# Create and initialize the game
	game = ManiacMansionGame.new()
	add_child(game)
	
	# Connect signals
	game.output_text.connect(_on_game_output)
	game.game_over.connect(_on_game_over)
	
	# Connect UI signals
	submit_button.pressed.connect(_on_submit_pressed)
	input_field.text_submitted.connect(_on_text_submitted)
	
	# Start the game
	game.start_game()
	input_field.grab_focus()

func _on_game_output(text: String):
	output_history += text + "\n"
	output_label.text = output_history
	
	# Auto-scroll to bottom
	await get_tree().create_timer(0.1).timeout
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func _on_submit_pressed():
	_process_input()

func _on_text_submitted(_text: String):
	_process_input()

func _process_input():
	var command = input_field.text.strip_edges()
	if command.is_empty():
		return
	
	# Echo the command
	output_history += "\n> " + command + "\n"
	output_label.text = output_history
	
	# Process the command
	game.process_command(command)
	
	# Clear input
	input_field.text = ""
	
	#	Be sure the input field get focus and enters edit mode
	await get_tree().create_timer(0.01).timeout
	input_field.grab_focus()
	input_field.edit()

func _on_game_over(won: bool):
	input_field.editable = false
	if won:
		output_history += "\n=== GAME COMPLETE ===\n"
	else:
		output_history += "\n=== GAME OVER ===\n"
	output_label.text = output_history


# Scene tree structure (create this in the Godot editor):
# Control (main.gd attached)
# └─ VBoxContainer
#    ├─ ScrollContainer
#    │  └─ OutputLabel (Label)
#    └─ HBoxContainer
#       ├─ InputField (LineEdit)
#       └─ SubmitButton (Button)
