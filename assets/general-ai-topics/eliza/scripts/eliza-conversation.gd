extends Node2D

# ELIZA-style conversational AI using pattern matching and reflection

var conversation_history = []

# Pattern-response pairs (pattern, responses array)
var patterns = [
	# Family patterns
	{
		"patterns": ["mother", "mom", "father", "dad", "sister", "brother", "family"],
		"responses": [
			"Tell me more about your family.",
			"How does that make you feel about your family?",
			"What role does your family play in this?",
			"Have you discussed this with your family?"
		]
	},
	
	# Feeling patterns
	{
		"patterns": ["i feel", "i'm feeling", "i am feeling"],
		"responses": [
			"Why do you feel that way?",
			"How long have you felt like this?",
			"What do you think is causing these feelings?",
			"Do you often feel this way?"
		]
	},
	
	# "I am" patterns
	{
		"patterns": ["i am", "i'm"],
		"responses": [
			"How long have you been {reflect}?",
			"Do you believe it's normal to be {reflect}?",
			"Why do you tell me you're {reflect}?",
			"What does being {reflect} mean to you?"
		]
	},
	
	# Desire patterns
	{
		"patterns": ["i want", "i need", "i wish"],
		"responses": [
			"Why do you want {reflect}?",
			"What would it mean to you if you got {reflect}?",
			"Suppose you got {reflect}, then what?",
			"What if you never got {reflect}?"
		]
	},
	
	# Question patterns
	{
		"patterns": ["why don't you", "why can't you"],
		"responses": [
			"Do you think I should {reflect}?",
			"Perhaps eventually I will {reflect}.",
			"Do you really want me to {reflect}?",
			"Why do you ask if I {reflect}?"
		]
	},
	
	# "You are" patterns
	{
		"patterns": ["you are", "you're"],
		"responses": [
			"Why do you think I am {reflect}?",
			"Does it please you to believe I am {reflect}?",
			"Perhaps you would like to be {reflect}.",
			"Do you sometimes wish you were {reflect}?"
		]
	},
	
	# Negative patterns
	{
		"patterns": ["i can't", "i cannot"],
		"responses": [
			"How do you know you can't {reflect}?",
			"Have you tried to {reflect}?",
			"Perhaps you could {reflect} if you tried.",
			"What would it take for you to {reflect}?"
		]
	},
	
	# Problem patterns
	{
		"patterns": ["problem", "worried", "concern", "trouble"],
		"responses": [
			"What do you think causes this problem?",
			"How does this problem make you feel?",
			"Have you had similar problems before?",
			"What steps have you taken to address this?"
		]
	},
	
	# Dream patterns
	{
		"patterns": ["dream", "nightmare"],
		"responses": [
			"What does that dream suggest to you?",
			"Do you dream often?",
			"What persons appear in your dreams?",
			"How do you feel about your dreams?"
		]
	},
	
	# Past patterns
	{
		"patterns": ["i remember", "i recall"],
		"responses": [
			"Why do you remember that now?",
			"What else does that remind you of?",
			"What feelings does that memory bring up?",
			"What is significant about that memory?"
		]
	},
	
	# Always patterns
	{
		"patterns": ["always", "never", "everyone", "nobody"],
		"responses": [
			"Can you think of a specific example?",
			"Really, {reflect}?",
			"That's quite absolute. Are you sure?",
			"When you say {reflect}, what do you mean exactly?"
		]
	},
	
	# Yes/No patterns
	{
		"patterns": ["^yes$", "^yeah$", "^yep$", "^sure$"],
		"responses": [
			"I see. And how does that make you feel?",
			"Can you elaborate on that?",
			"What makes you so certain?",
			"Tell me more."
		]
	},
	
	{
		"patterns": ["^no$", "^nope$", "^not really$"],
		"responses": [
			"Why not?",
			"Are you sure?",
			"Can you explain why you feel that way?",
			"What would it take to change your mind?"
		]
	},
]

# Generic responses when no pattern matches
var generic_responses = [
	"Tell me more about that.",
	"How does that make you feel?",
	"Why do you say that?",
	"I see. Go on.",
	"That's interesting. What else?",
	"Can you elaborate?",
	"What does that suggest to you?",
	"How long have you felt this way?",
	"What do you think about that?",
	"Please continue."
]

# Reflection dictionary for pronoun switching
var reflections = {
	"am": "are",
	"are": "am",
	"i": "you",
	"i'd": "you would",
	"i've": "you have",
	"i'll": "you will",
	"my": "your",
	"me": "you",
	"you": "me",
	"your": "my",
	"yours": "mine",
	"you're": "I am",
	"you've": "I have",
	"you'll": "I will",
	"myself": "yourself",
	"yourself": "myself"
}

func _ready():
	print("ELIZA Chatbot initialized. Type 'quit' or 'bye' to exit.")
	print("ELIZA: Hello. How are you feeling today?")
	conversation_history.append("Hello. How are you feeling today?")

	#example_conversation()

# Main function to get response
func get_response(user_input: String) -> String:
	var input_lower = user_input.to_lower().strip_edges()
	
	# Check for exit commands
	if input_lower in ["quit", "bye", "exit", "goodbye"]:
		return "Goodbye. It was nice talking to you."
	
	# Check for greeting
	if input_lower in ["hello", "hi", "hey"]:
		return "Hello. What brings you here today?"
	
	# Try to match patterns
	for pattern_group in patterns:
		for pattern in pattern_group["patterns"]:
			if pattern.begins_with("^") and pattern.ends_with("$"):
				# Exact match pattern
				var clean_pattern = pattern.trim_prefix("^").trim_suffix("$")
				if input_lower == clean_pattern:
					return get_pattern_response(pattern_group["responses"], input_lower)
			else:
				# Substring match
				if input_lower.find(pattern) != -1:
					return get_pattern_response(pattern_group["responses"], input_lower)
	
	# No pattern matched, use generic response
	return generic_responses[randi() % generic_responses.size()]

# Get response from pattern and apply reflection if needed
func get_pattern_response(responses: Array, user_input: String) -> String:
	var response = responses[randi() % responses.size()]
	
	# If response contains {reflect}, replace it with reflected input
	if response.find("{reflect}") != -1:
		var reflected = reflect_input(user_input)
		response = response.replace("{reflect}", reflected)
	
	return response

# Reflect pronouns in user input
func reflect_input(input: String) -> String:
	var words = input.split(" ")
	var reflected_words = []
	
	for word in words:
		var lower_word = word.to_lower()
		if reflections.has(lower_word):
			reflected_words.append(reflections[lower_word])
		else:
			reflected_words.append(word)
	
	return " ".join(reflected_words)

# Process a conversation turn
func chat(user_input: String) -> String:
	var response = get_response(user_input)
	conversation_history.append("YOU: " + user_input)
	conversation_history.append("ELIZA: " + response)
	return response

# Get conversation history
func get_history() -> String:
	return "\n".join(conversation_history)

# Reset conversation
func reset() -> void:
	conversation_history.clear()
	print("ELIZA: Hello. How are you feeling today?")
	conversation_history.append("Hello. How are you feeling today?")


# Example usage in a game loop or UI
func example_conversation():
	print(chat("I'm feeling sad today"))
	print(chat("My mother never understood me"))
	print(chat("I want to be happy"))
	print(chat("Why can't you help me"))
	print(chat("bye"))
