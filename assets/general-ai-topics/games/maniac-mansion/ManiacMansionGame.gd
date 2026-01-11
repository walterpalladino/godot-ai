extends Node

# Maniac Mansion-inspired Text Adventure
# Core game logic

class_name ManiacMansionGame

signal output_text(text: String)
signal game_over(won: bool)

var current_room: String = "driveway"
var inventory: Array[String] = []
var game_state: Dictionary = {
	"front_door_locked": true,
	"basement_door_locked": true,
	"has_met_edna": false,
	"purple_tentacle_fed": false,
	"generator_running": false,
	"lab_door_open": false,
	"rescued_sandy": false
}

var rooms: Dictionary = {
	"driveway": {
		"name": "Driveway",
		"desc": "You stand before a creepy Victorian mansion. The paint is peeling and strange lights flicker in the upper windows. A gravel path leads to the front door. There's a mailbox here.",
		"exits": {"north": "front_porch", "south": "street"},
		"items": []
	},
	"street": {
		"name": "Street",
		"desc": "You're on a quiet suburban street. The mansion looms behind you. There's nothing interesting here.",
		"exits": {"north": "driveway"},
		"items": []
	},
	"front_porch": {
		"name": "Front Porch",
		"desc": "A wooden porch with creaking boards. The front door is old and imposing. A doorbell hangs to the right.",
		"exits": {"south": "driveway", "north": "foyer"},
		"items": ["doormat"]
	},
	"foyer": {
		"name": "Foyer",
		"desc": "A dusty entrance hall with a grand staircase leading up. Portraits on the walls seem to watch you. Doors lead east and west.",
		"exits": {"south": "front_porch", "east": "living_room", "west": "kitchen", "up": "upstairs_hall"},
		"items": []
	},
	"living_room": {
		"name": "Living Room",
		"desc": "A dimly lit room filled with antique furniture covered in dust. A strange humming sound comes from somewhere below.",
		"exits": {"west": "foyer", "down": "basement"},
		"items": ["old_key"]
	},
	"kitchen": {
		"name": "Kitchen",
		"desc": "A grimy kitchen with 1950s appliances. The refrigerator hums loudly. There's a door leading outside to the north.",
		"exits": {"east": "foyer", "north": "backyard"},
		"items": ["pepperoni"]
	},
	"basement": {
		"name": "Basement",
		"desc": "A dark basement filled with scientific equipment and strange machines. There's a locked door to the north leading to what looks like a laboratory.",
		"exits": {"up": "living_room", "north": "laboratory"},
		"items": ["wrench"]
	},
	"laboratory": {
		"name": "Secret Laboratory",
		"desc": "Dr. Fred's laboratory! Bubbling beakers, electrical equipment, and a mysterious machine dominate the room. Your friend Sandy is trapped in a glass chamber!",
		"exits": {"south": "basement"},
		"items": ["lab_key"]
	},
	"backyard": {
		"name": "Backyard",
		"desc": "An overgrown backyard. A purple tentacle creature is here, looking hungry!",
		"exits": {"south": "kitchen"},
		"items": []
	},
	"upstairs_hall": {
		"name": "Upstairs Hallway",
		"desc": "A long hallway with several doors. Family portraits line the walls.",
		"exits": {"down": "foyer", "east": "green_tentacle_room"},
		"items": []
	},
	"green_tentacle_room": {
		"name": "Green Tentacle's Room",
		"desc": "A cozy room with a record player and musical instruments. The friendly Green Tentacle lives here.",
		"exits": {"west": "upstairs_hall"},
		"items": ["record"]
	}
}

# Add items to initial room states
func _ready():
	rooms["driveway"]["items"] = ["flashlight"]
	rooms["front_porch"]["items"] = ["doormat"]
	rooms["living_room"]["items"] = ["old_key"]
	rooms["kitchen"]["items"] = ["pepperoni"]
	rooms["basement"]["items"] = ["wrench"]

func start_game():
	emit_output("\n=== MANIAC MANSION ===\n")
	emit_output("Your friend Sandy has been kidnapped by the mad scientist Dr. Fred!")
	emit_output("You must explore the mansion and rescue her!\n")
	emit_output("Commands: look, go [direction], take [item], use [item], inventory, examine [item]\n")
	look()

func process_command(cmd: String) -> void:
	var parts = cmd.to_lower().strip_edges().split(" ", false)
	if parts.is_empty():
		emit_output("Please enter a command.")
		return
	
	var verb = parts[0]
	var noun = parts[1] if parts.size() > 1 else ""
	
	match verb:
		"look", "l":
			look()
		"go", "move", "walk":
			if noun.is_empty():
				emit_output("Go where? (north, south, east, west, up, down)")
			else:
				go(noun)
		"take", "get", "grab":
			if noun.is_empty():
				emit_output("Take what?")
			else:
				take(noun)
		"use":
			if noun.is_empty():
				emit_output("Use what?")
			else:
				use_item(noun)
		"inventory", "i":
			show_inventory()
		"examine", "x":
			if noun.is_empty():
				emit_output("Examine what?")
			else:
				examine(noun)
		"help":
			emit_output("Commands: look, go [dir], take [item], use [item], inventory, examine [item]")
		_:
			emit_output("I don't understand that command. Type 'help' for commands.")

func look():
	var room = rooms[current_room]
	emit_output("\n" + room["name"])
	emit_output(room["desc"])
	
	if room["items"].size() > 0:
		emit_output("\nYou can see: " + ", ".join(room["items"]))
	
	var exits = []
	for direction in room["exits"].keys():
		exits.append(direction)
	if exits.size() > 0:
		emit_output("Exits: " + ", ".join(exits))

func go(direction: String):
	var room = rooms[current_room]
	
	# Special door checks
	if current_room == "front_porch" and direction == "north":
		if game_state["front_door_locked"]:
			emit_output("The front door is locked. Maybe there's a key under the doormat?")
			return
	
	if current_room == "basement" and direction == "north":
		if game_state["basement_door_locked"]:
			emit_output("The laboratory door is locked. You need to find a way to open it.")
			return
	
	if direction in room["exits"]:
		current_room = room["exits"][direction]
		look()
		
		# Check win condition
		if current_room == "laboratory" and not game_state["rescued_sandy"]:
			emit_output("\n*** You found Sandy! But you need to free her from the chamber! ***")
	else:
		emit_output("You can't go that way.")

func take(item: String):
	var room = rooms[current_room]
	
	if item in room["items"]:
		room["items"].erase(item)
		inventory.append(item)
		emit_output("Taken: " + item.replace("_", " "))
	else:
		emit_output("You don't see that here.")

func use_item(item: String):
	if not item in inventory:
		emit_output("You don't have that item.")
		return
	
	match item:
		"doormat":
			if current_room == "front_porch":
				emit_output("You lift the doormat and find a rusty key!")
				inventory.append("rusty_key")
				emit_output("Taken: rusty key")
		
		"rusty_key":
			if current_room == "front_porch":
				emit_output("You unlock the front door with the rusty key!")
				game_state["front_door_locked"] = false
			else:
				emit_output("Nothing to unlock here.")
		
		"pepperoni":
			if current_room == "backyard":
				emit_output("You feed the pepperoni to the Purple Tentacle! It's happy now!")
				game_state["purple_tentacle_fed"] = true
				inventory.erase("pepperoni")
			else:
				emit_output("You eat a slice. Delicious, but not helpful right now.")
		
		"wrench":
			if current_room == "basement":
				emit_output("You use the wrench to force open the laboratory door!")
				game_state["basement_door_locked"] = false
			else:
				emit_output("Nothing to fix here.")
		
		"lab_key":
			if current_room == "laboratory":
				emit_output("\n*** YOU WIN! ***")
				emit_output("You use the lab key to free Sandy from the chamber!")
				emit_output("You both escape the mansion safely!")
				game_state["rescued_sandy"] = true
				emit_game_over(true)
			else:
				emit_output("Nothing to unlock here.")
		
		_:
			emit_output("You can't use that item here.")

func examine(item: String):
	var descriptions = {
		"flashlight": "A dusty old flashlight. Still works!",
		"doormat": "A worn doormat. Something might be hidden under it.",
		"rusty_key": "An old rusty key. Might open the front door.",
		"old_key": "A tarnished brass key.",
		"pepperoni": "A stick of pepperoni. The Purple Tentacle might like this!",
		"wrench": "A heavy wrench. Good for forcing open stuck doors.",
		"lab_key": "A shiny key labeled 'SPECIMEN CHAMBER'",
		"record": "A vinyl record of tentacle music."
	}
	
	if item in inventory or item in rooms[current_room]["items"]:
		if item in descriptions:
			emit_output(descriptions[item])
		else:
			emit_output("Nothing special about that.")
	else:
		emit_output("You don't see that here.")

func show_inventory():
	if inventory.is_empty():
		emit_output("You're not carrying anything.")
	else:
		var items = []
		for item in inventory:
			items.append(item.replace("_", " "))
		emit_output("You're carrying: " + ", ".join(items))

func emit_output(text: String):
	output_text.emit(text)

func emit_game_over(won: bool):
	game_over.emit(won)
	
