extends Node2D

# Current theme - change this to switch themes
var current_theme = "nature"  # Options: "nature", "spring", "summer", "autumn", "winter", "emotions", "water", "sky"

# Themed word pools organized by syllable count
var themed_words = {
	"nature": {
		"1_syl": ["spring", "breeze", "leaf", "moon", "sun", "cloud", "rain", "snow", "wind", "bird",
				  "dawn", "dusk", "night", "fog", "mist", "stream", "pond", "lake", "tree", "pine",
				  "stone", "path", "hill", "field", "bloom", "frost", "dew", "sky", "star", "wave"],
		"2_syl": ["flowing", "dancing", "shining", "sacred", "gentle", "golden", "silver", 
				  "mountain", "river", "garden", "meadow", "temple", "lotus", "willow",
				  "twilight", "morning", "evening", "rainbow", "thunder", "ancient"],
		"3_syl": ["quietly", "peacefully", "beautiful", "wandering", "glistening", "silently",
				  "eternal", "whispering", "glimmering", "butterfly", "dragonfly", "waterfall"]
	},
	
	"spring": {
		"1_syl": ["bloom", "bud", "green", "growth", "warmth", "rain", "breeze", "song", "nest", "egg",
				  "sprout", "dawn", "dew", "hope", "life", "light", "bird", "lamb", "fresh", "new"],
		"2_syl": ["blooming", "awake", "emerging", "newborn", "tender", "cherry", "robin", "tulip",
				  "seedling", "rainfall", "sunshine", "verdant", "youthful", "playful", "hopeful"],
		"3_syl": ["awakening", "renewal", "blossoming", "arrival", "butterfly", "opening",
				  "energy", "fertile", "revival", "beginning", "emerging"]
	},
	
	"summer": {
		"1_syl": ["heat", "sun", "bright", "warm", "long", "day", "swim", "beach", "sand", "wave",
				  "glow", "shine", "blaze", "gold", "green", "fruit", "bees", "hum", "still", "calm"],
		"2_syl": ["golden", "burning", "endless", "lazy", "cricket", "sunset", "firefly", "heated",
				  "humid", "ripened", "glowing", "blazing", "sultry", "vibrant", "summit"],
		"3_syl": ["radiant", "lingering", "infinite", "cicada", "abundance", "intensity",
				  "eternal", "shimmering", "brilliant", "luxurious", "drowsy"]
	},
	
	"autumn": {
		"1_syl": ["fall", "leaf", "red", "gold", "rust", "brown", "chill", "brisk", "wind", "change",
				  "crisp", "cool", "ripe", "corn", "wheat", "mist", "fog", "dusk", "geese", "moon"],
		"2_syl": ["falling", "harvest", "amber", "crimson", "withered", "fading", "cooling", "turning",
				  "orange", "scarlet", "dying", "migrant", "shorter", "chilly", "rustling"],
		"3_syl": ["falling leaves", "forever", "transition", "surrendered", "September", "October",
				  "November", "departing", "releasing", "mellowing", "mystery"]
	},
	
	"winter": {
		"1_syl": ["snow", "ice", "frost", "cold", "white", "chill", "freeze", "pine", "still", "bare",
				  "sleep", "rest", "night", "long", "deep", "star", "moon", "wind", "storm", "peace"],
		"2_syl": ["frozen", "silent", "sleeping", "bitter", "crystal", "blanket", "slumber", "barren",
				  "icy", "snowy", "frigid", "quiet", "hollow", "empty", "resting"],
		"3_syl": ["solitude", "silvery", "beautiful", "clarity", "eternity", "forever",
				  "quietude", "December", "January", "hibernal", "slumbering"]
	},
	
	"emotions": {
		"1_syl": ["joy", "peace", "love", "grief", "hope", "fear", "pain", "calm", "rage", "bliss",
				  "gloom", "pride", "shame", "warmth", "trust", "loss", "dream", "faith", "doubt", "grace"],
		"2_syl": ["longing", "yearning", "grateful", "peaceful", "joyful", "tender", "aching", "haunted",
				  "healing", "hoping", "loving", "mourning", "seeking", "anxious", "weightless"],
		"3_syl": ["harmony", "sorrowful", "beautiful", "quietly", "rememb'ring", "forgetting",
				  "wondering", "embracing", "accepting", "releasing", "uncertain"]
	},
	
	"water": {
		"1_syl": ["stream", "pond", "lake", "sea", "rain", "wave", "tide", "flow", "drift", "pool",
				  "spring", "mist", "dew", "drop", "splash", "shore", "deep", "blue", "clear", "wet"],
		"2_syl": ["flowing", "river", "ocean", "rainfall", "current", "ripple", "fountain", "cascade",
				  "droplet", "surface", "mirror", "drinking", "winding", "endless", "boundless"],
		"3_syl": ["eternal", "whispering", "murmuring", "wandering", "reflecting", "clarity",
				  "waterfall", "trickling", "infinite", "transparent", "unity"]
	},
	
	"sky": {
		"1_syl": ["sky", "cloud", "star", "moon", "sun", "dawn", "dusk", "night", "light", "dark",
				  "blue", "grey", "white", "gold", "storm", "wind", "glow", "bright", "dim", "vast"],
		"2_syl": ["twilight", "morning", "evening", "sunlight", "moonlight", "starlight", "boundless",
				  "endless", "cloudless", "misty", "floating", "soaring", "heaven", "distant"],
		"3_syl": ["eternal", "celestial", "horizon", "firmament", "galaxies", "glimmering",
				  "infinite", "ascending", "transcendent", "empyrean", "atmosphere"]
	}
}

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

	print ("--------------------------------")
	current_theme = "nature"  # Options: "nature", "spring", "summer", "autumn", "winter", "emotions", "water", "sky"
	var haiku = generate_haiku()
	print(haiku)

	print ("--------------------------------")
	current_theme = "sky"  # Options: "nature", "spring", "summer", "autumn", "winter", "emotions", "water", "sky"
	haiku = generate_haiku()
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
	var theme_data = themed_words.get(current_theme, themed_words["nature"])
	
	match syllables:
		1:
			word_pool = theme_data.get("1_syl", [])
		2:
			word_pool = theme_data.get("2_syl", [])
		3:
			word_pool = theme_data.get("3_syl", [])
		_:
			return ""
	
	if word_pool.is_empty():
		return ""
	
	return word_pool[randi() % word_pool.size()]

# Call this function to change the theme
func set_theme(theme_name: String) -> void:
	if themed_words.has(theme_name):
		current_theme = theme_name
		print("Theme changed to: " + theme_name)
	else:
		print("Theme not found: " + theme_name)

# Get a list of available themes
func get_available_themes() -> Array:
	return themed_words.keys()

# Call this function to generate a new haiku on demand
func get_new_haiku() -> String:
	return generate_haiku()
