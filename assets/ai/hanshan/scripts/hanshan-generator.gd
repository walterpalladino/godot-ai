extends Node2D

#Key Features:
#Authentic Hanshan characteristics:
#
#Conversational, informal tone ("People ask me why I live here")
#Zen Buddhist themes (solitude, simplicity, non-attachment)
#Mountain hermit perspective
#Mix of observations and gentle wisdom
#Irregular meter (4-8 lines, varying lengths)
#Self-deprecating humor and acceptance
#
#Structure:
#
#Opening line sets the scene or poses a question
#Middle lines provide observations and natural imagery
#Closing line offers zen insight or acceptance
#Transitional phrases create natural flow
#
#Example poems you might get:
#I climb the mountain path alone
#sometimes white clouds gather and disperse
#each day my shadow is my only companion
#this is enough
#People ask me why I live here
#the stream mutters to itself below
#but I've learned the language of silence
#at night the moon understands better than people
#honestly I wouldn't trade places with anyone
#The generator creates poems that feel like genuine Hanshan - contemplative, conversational, with that characteristic blend of earthiness and enlightenment. Each poem has the feeling of a hermit casually sharing observations about mountain life and spiritual practice.


# Hanshan poems are conversational, zen-influenced, irregular meter
# Themes: solitude, mountains, nature, spiritual insight, simple living

# Line structures (Hanshan poems vary 4-8 lines typically)
var poem_lengths = [4, 5, 6, 7, 8]

# Opening lines - set the scene or pose a question
var opening_lines = [
	"I climb the mountain path alone",
	"People ask me why I live here",
	"In these cold mountains",
	"Who understands this life of mine",
	"Years pass like flowing water",
	"I sit beneath the ancient pine",
	"The world below is full of noise",
	"My hut stands empty most days",
	"No one comes to visit anymore",
	"I've forgotten the way back down",
	"Spring comes but who notices",
	"They say I'm crazy living here",
	"I read old sutras by candlelight",
	"My rice bowl sits on the wooden shelf",
	"The monastery bells reach me sometimes",
]

# Middle lines - observations, reflections, natural imagery
var middle_lines = [
	"white clouds gather and disperse",
	"the stream mutters to itself below",
	"pine needles carpet the stone steps",
	"I watch birds without thinking",
	"monkeys chatter in the bamboo",
	"mist conceals the valley floor",
	"my shadow is my only companion",
	"the wind knows all my secrets",
	"I've worn this robe for ten years",
	"my footprints fade behind me",
	"the moon understands better than people",
	"I boil wild greens for dinner",
	"moss grows thick on everything here",
	"I've learned the language of silence",
	"seasons turn but I remain",
	"my hair has gone completely gray",
	"I laugh at my younger self",
	"the sutras make more sense now",
	"I own nothing worth stealing",
	"my desires have grown simple",
]

# Closing lines - zen insights, acceptance, or gentle wisdom
var closing_lines = [
	"this is enough",
	"what more could I need",
	"let them laugh if they want",
	"I've found what I was seeking",
	"the path was here all along",
	"words cannot capture this",
	"even this thought dissolves",
	"tomorrow I may understand better",
	"or perhaps understanding isn't the point",
	"the mountain doesn't judge me",
	"I sleep when tired wake when rested",
	"isn't this the way things are",
	"let the world rush past below",
	"here everything moves slowly",
	"I wouldn't trade places with anyone",
]

# Transitional phrases for flow
var transitions = [
	"meanwhile",
	"sometimes",
	"each day",
	"at night",
	"when I think about it",
	"honestly",
	"people say",
	"but",
	"still",
	"even so",
	"perhaps",
	"who knows",
	"anyway",
	"",  # Empty for direct continuation
]

func _ready():
	# Generate and print a Hanshan-style poem when ready
	var poem = generate_hanshan_poem()
	print(poem)

func generate_hanshan_poem() -> String:
	var length = poem_lengths[randi() % poem_lengths.size()]
	var lines = []
	
	# Always start with an opening
	lines.append(opening_lines[randi() % opening_lines.size()])
	
	# Fill middle with observations (length - 2 lines)
	var middle_count = length - 2
	for i in range(middle_count):
		var transition = transitions[randi() % transitions.size()]
		var middle = middle_lines[randi() % middle_lines.size()]
		
		if transition != "":
			lines.append(transition + " " + middle)
		else:
			lines.append(middle)
	
	# End with a closing reflection
	lines.append(closing_lines[randi() % closing_lines.size()])
	
	return "\n".join(lines)

# Generate a new poem on demand
func get_new_poem() -> String:
	return generate_hanshan_poem()

# Generate multiple poems
func generate_poems(count: int) -> Array:
	var poems = []
	for i in range(count):
		poems.append(generate_hanshan_poem())
	return poems
