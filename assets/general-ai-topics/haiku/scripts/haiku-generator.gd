extends Node2D

# Word pools organized by syllable count
#var words_1_syl = ["spring", "breeze", "leaf", "moon", "sun", "cloud", "rain", "snow", "wind", "bird"]
#var words_2_syl = ["flowing", "dancing", "shining", "whis'pring", "sacred", "gentle", "golden", "silver", "mountain", "river"]
#var words_3_syl = ["quietly", "peacefully", "beautiful", "wandering", "glistening", "silently", "awakens", "eternal"]
# Word pools organized by syllable count
var words_1_syl = [
	"spring", "breeze", "leaf", "moon", "sun", "cloud", "rain", "snow", "wind", "bird",
	"dawn", "dusk", "night", "fog", "mist", "stream", "pond", "lake", "tree", "pine",
	"stone", "path", "hill", "field", "bloom", "frost", "dew", "sky", "star", "wave",
	"shore", "tide", "moss", "branch", "root", "seed", "light", "shade", "flight", "nest"
]

var words_2_syl = [
	"flowing", "dancing", "shining", "whis'pring", "sacred", "gentle", "golden", "silver", 
	"mountain", "river", "garden", "meadow", "temple", "lotus", "cherry", "willow",
	"twilight", "morning", "evening", "rainbow", "thunder", "lightning", "autumn", "winter",
	"summer", "blossom", "petal", "fallen", "rising", "silent", "peaceful", "ancient",
	"distant", "flowing", "burning", "frozen", "hollow", "countless", "endless", "timeless"
]

var words_3_syl = [
	"quietly", "peacefully", "beautiful", "wandering", "glistening", "silently", "awakens", 
	"eternal", "whispering", "glimmering", "shimmering", "flickering", "radiant", "transcendent",
	"rememb'ring", "forgetting", "returning", "becoming", "united", "surrendered", "emerging",
	"butterfly", "dragonfly", "cicada", "juniper", "cherry tree", "mountainside", "waterfall",
	"forever", "solitude", "harmony", "melody", "mystery", "memory", "reverie"
]

# Phrase templates for each line (5-7-5 syllable structure)
#var line1_patterns = [
	#[1, 1, 3],  # 1 + 1 + 3 = 5
	#[2, 3],     # 2 + 3 = 5
	#[1, 2, 2],  # 1 + 2 + 2 = 5
#]
#
#var line2_patterns = [
	#[1, 2, 2, 2],  # 1 + 2 + 2 + 2 = 7
	#[2, 2, 3],     # 2 + 2 + 3 = 7
	#[1, 3, 3],     # 1 + 3 + 3 = 7
	#[3, 2, 2],     # 3 + 2 + 2 = 7
#]
#
#var line3_patterns = [
	#[1, 1, 3],  # 1 + 1 + 3 = 5
	#[2, 3],     # 2 + 3 = 5
	#[3, 2],     # 3 + 2 = 5
#]

# Phrase templates for each line (5-7-5 syllable structure)
var line1_patterns = [
	[1, 1, 3],    # 1 + 1 + 3 = 5
	[2, 3],       # 2 + 3 = 5
	[1, 2, 2],    # 1 + 2 + 2 = 5
	[3, 2],       # 3 + 2 = 5
	[1, 1, 1, 2], # 1 + 1 + 1 + 2 = 5
	[2, 1, 2],    # 2 + 1 + 2 = 5
	[3, 1, 1],    # 3 + 1 + 1 = 5
	[1, 1, 1, 1, 1], # 1 + 1 + 1 + 1 + 1 = 5
	[2, 2, 1],    # 2 + 2 + 1 = 5
]

var line2_patterns = [
	[1, 2, 2, 2],    # 1 + 2 + 2 + 2 = 7
	[2, 2, 3],       # 2 + 2 + 3 = 7
	[1, 3, 3],       # 1 + 3 + 3 = 7
	[3, 2, 2],       # 3 + 2 + 2 = 7
	[2, 3, 2],       # 2 + 3 + 2 = 7
	[3, 3, 1],       # 3 + 3 + 1 = 7
	[1, 1, 2, 3],    # 1 + 1 + 2 + 3 = 7
	[2, 1, 2, 2],    # 2 + 1 + 2 + 2 = 7
	[1, 2, 1, 3],    # 1 + 2 + 1 + 3 = 7
	[3, 1, 3],       # 3 + 1 + 3 = 7
	[1, 1, 1, 2, 2], # 1 + 1 + 1 + 2 + 2 = 7
	[2, 2, 1, 2],    # 2 + 2 + 1 + 2 = 7
	[1, 3, 2, 1],    # 1 + 3 + 2 + 1 = 7
]

var line3_patterns = [
	[1, 1, 3],    # 1 + 1 + 3 = 5
	[2, 3],       # 2 + 3 = 5
	[3, 2],       # 3 + 2 = 5
	[1, 2, 2],    # 1 + 2 + 2 = 5
	[2, 2, 1],    # 2 + 2 + 1 = 5
	[3, 1, 1],    # 3 + 1 + 1 = 5
	[1, 1, 1, 2], # 1 + 1 + 1 + 2 = 5
	[2, 1, 2],    # 2 + 1 + 2 = 5
	[1, 1, 1, 1, 1], # 1 + 1 + 1 + 1 + 1 = 5
]

func _ready():
	# Generate and print a haiku when the node is ready
	var haiku = generate_haiku()
	print(haiku)

func generate_haiku() -> String:
	var line1 = generate_line(line1_patterns)
	var line2 = generate_line(line2_patterns)
	var line3 = generate_line(line3_patterns)
	
	return line1 + "\n" + line2 + "\n" + line3

func generate_line(patterns: Array) -> String:
	# Pick a random pattern
	var pattern = patterns[randi() % patterns.size()]
	var words = []
	
	# Build the line according to the pattern
	for syllable_count in pattern:
		var word = get_random_word(syllable_count)
		words.append(word)
	
	return " ".join(words)

func get_random_word(syllables: int) -> String:
	var word_pool = []
	
	match syllables:
		1:
			word_pool = words_1_syl
		2:
			word_pool = words_2_syl
		3:
			word_pool = words_3_syl
		_:
			return ""
	
	if word_pool.is_empty():
		return ""
	
	return word_pool[randi() % word_pool.size()]

# Call this function to generate a new haiku on demand
func get_new_haiku() -> String:
	return generate_haiku()
