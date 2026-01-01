extends Node

class_name MarkovModel

#	Manual run
#var markov = MarkovModel.new()
#markov.order = 2
#markov.load_from_file("res://data/my_text.txt")
#
## Generate text
#var text = markov.generate_text(50)
#print(text)
#
## Get statistics
#print(markov.get_stats())



@export_file_path("*.txt") var trainer_file_path : String
@export_dir() var model_path : String

# The order of the Markov chain (how many previous states to consider)
@export var order: int = 2

# Dictionary storing the transition chains
var chains: Dictionary = {}

# Stores all possible starting states
var start_states: Array = []


func _ready():

	if trainer_file_path:

		print("Creating fodel from file ... ")
		
		var success = load_from_file(trainer_file_path)
		if success:
			print("Markov model built successfully!")
			print("Generated text: ", generate_text(100))
			
			## Get statistics
			print(get_stats())
			
			print("Saving model.")
			save_model(model_path + "/markov-model.json")

		else:
			print("Failed to load file")

	else:
		
		if model_path:
			
			print("Loading model.")
			var success = load_model(model_path + "/markov-model.json")
			
			if success:
				print("Markov model built successfully!")
				print("Generated text: ", generate_text(100))
				
				## Get statistics
				print(get_stats())


# Load text from file and build the Markov model
func load_from_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("File not found: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Could not open file: " + file_path)
		return false
	
	var text = file.get_as_text()
	file.close()
	
	build_model(text)
	return true


# Build the Markov model from input text
func build_model(text: String) -> void:
	chains.clear()
	start_states.clear()
	
	# Tokenize the text into words
	var words = text.split(" ", false)
	
	# Remove extra whitespace and clean tokens
	for i in range(words.size()):
		words[i] = words[i].strip_edges()
	
	if words.size() < order + 1:
		push_warning("Text too short for order " + str(order))
		return
	
	# Build the chain
	for i in range(words.size() - order):
		# Create the state (tuple of 'order' words)
		var state = []
		for j in range(order):
			state.append(words[i + j])
		
		var state_key = "_".join(state)
		var next_word = words[i + order]
		
		# Store starting states
		if i == 0:
			start_states.append(state_key)
		
		# Add to chains dictionary
		if not chains.has(state_key):
			chains[state_key] = []
		
		chains[state_key].append(next_word)


# Generate text using the Markov model
func generate_text(max_words: int = 50, seed_text: String = "") -> String:
	if chains.is_empty():
		push_warning("Model not trained yet")
		return ""
	
	var result = []
	var current_state: String
	
	# Choose starting state
	if seed_text.is_empty():
		if start_states.is_empty():
			current_state = chains.keys()[randi() % chains.keys().size()]
		else:
			current_state = start_states[randi() % start_states.size()]
	else:
		# Try to find a matching state from seed
		var seed_words = seed_text.split(" ", false)
		if seed_words.size() >= order:
			var seed_state = []
			for i in range(order):
				seed_state.append(seed_words[i])
			current_state = "_".join(seed_state)
			
			if not chains.has(current_state):
				# Fallback to random start
				current_state = start_states[randi() % start_states.size()]
		else:
			current_state = start_states[randi() % start_states.size()]
	
	# Add initial state words to result
	result.append_array(current_state.split("_"))
	
	# Generate words
	for i in range(max_words - order):
		if not chains.has(current_state):
			break
		
		# Pick a random next word from possible transitions
		var possible_next = chains[current_state]
		var next_word = possible_next[randi() % possible_next.size()]
		result.append(next_word)
		
		# Update current state
		var state_words = current_state.split("_")
		state_words.remove_at(0)
		state_words.append(next_word)
		current_state = "_".join(state_words)
	
	return " ".join(result)


# Get statistics about the model
func get_stats() -> Dictionary:
	return {
		"total_states": chains.size(),
		"start_states": start_states.size(),
		"order": order,
		"avg_transitions": _calculate_avg_transitions()
	}


func _calculate_avg_transitions() -> float:
	if chains.is_empty():
		return 0.0
	
	var total = 0
	for state in chains:
		total += chains[state].size()
	
	return float(total) / float(chains.size())


# Save model to a file (optional feature)
func save_model(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not save model to: " + file_path)
		return false
	
	var data = {
		"order": order,
		"chains": chains,
		"start_states": start_states
	}
	
	file.store_string(JSON.stringify(data))
	file.close()
	return true


# Load model from a saved file (optional feature)
func load_model(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("Model file not found: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Could not load model from: " + file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("Failed to parse model JSON")
		return false
	
	var data = json.data
	order = data.order
	chains = data.chains
	start_states = data.start_states
	
	return true
