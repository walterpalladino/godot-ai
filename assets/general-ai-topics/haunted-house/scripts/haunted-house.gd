extends Control

var output_text: RichTextLabel
var input_field: LineEdit
var inventory: Array = []
var current_room: String = "outside"
var game_over: bool = false
var know_plugh: bool = false
var trapped: bool = false
var trap_counter: int = 0
var exit_counter: int = 0
var rope_dropped: bool = false
var ghosts_killed: int = 0
var passed_locked_door: bool = false

var rooms = {
	"outside": {
		"desc": "You are standing outside a creepy old haunted house. There is a PAPER on the ground.",
		"items": ["paper"],
		"exits": {"enter": "must_say_plugh"}
	},
	"entrance": {
		"desc": "You are in the entrance hall of the haunted house. Exits are EAST and WEST.",
		"items": [],
		"exits": {"e": "knife_room", "w": "outside_after"}
	},
	"outside_after": {
		"desc": "You have safely exited the house.",
		"items": [],
		"exits": {}
	},
	"knife_room": {
		"desc": "A dark room with a KNIFE and a SCROLL on the floor. Exits are EAST and WEST.",
		"items": ["knife", "scroll"],
		"exits": {"e": "hallway1", "w": "entrance", "n": "death", "s": "death"}
	},
	"hallway1": {
		"desc": "A long hallway. There is a BUCKET of water here. Exits are SOUTH and NORTH.",
		"items": ["bucket"],
		"exits": {"s": "hallway2", "n": "knife_room"}
	},
	"hallway2": {
		"desc": "Another section of hallway. Exits are SOUTH, NORTH, and EAST.",
		"items": [],
		"exits": {"s": "trap_room", "n": "hallway1", "e": "hallway3"}
	},
	"hallway3": {
		"desc": "You are in a hallway. Exits are WEST and EAST.",
		"items": [],
		"exits": {"w": "hallway2", "e": "trap_room"}
	},
	"trap_room": {
		"desc": "A peculiar room. There is a CABINET here. Exits appear to be NORTH, SOUTH, EAST, and WEST.",
		"items": [],
		"exits": {"n": "trap_room", "s": "trap_room", "e": "trap_room", "w": "trap_room"}
	},
	"panel_room": {
		"desc": "A small room with wooden panels. There is a PANEL on the wall and some ROPE coiled in the corner.",
		"items": ["rope"],
		"exits": {"s": "panel_room", "n": "death"}
	},
	"locked_hallway": {
		"desc": "A hallway with a locked door to the south. You need a KEY to pass.",
		"items": [],
		"exits": {"n": "panel_room", "s": "spooky_room", "e": "death", "w": "death"}
	},
	"spooky_room": {
		"desc": "A spooky room. A voice whispers 'Turn back now or face certain doom going EAST...'",
		"items": [],
		"exits": {"n": "locked_hallway", "e": "rope_room"}
	},
	"rope_room": {
		"desc": "There is a hole in the ceiling leading upward. You need ROPE to climb up.",
		"items": [],
		"exits": {"w": "spooky_room"}
	},
	"second_floor": {
		"desc": "You are on the second floor. There is a SWORD here with writing on it. Exits are EAST and WEST.",
		"items": ["sword"],
		"exits": {"e": "ghost1", "w": "ghost3"}
	},
	"ghost1": {
		"desc": "A GHOST blocks your path! You must KILL it to proceed. Exits are WEST and SOUTH.",
		"items": [],
		"exits": {"w": "second_floor", "s": "ghost2"}
	},
	"ghost2": {
		"desc": "Another GHOST appears! KILL it! Exits are NORTH and EAST.",
		"items": [],
		"exits": {"n": "ghost1", "e": "ghost3"}
	},
	"ghost3": {
		"desc": "A third GHOST emerges! KILL it! Exits are WEST, EAST, and SOUTH.",
		"items": [],
		"exits": {"w": "ghost2", "e": "second_floor", "s": "head_ghost"}
	},
	"head_ghost": {
		"desc": "The HEAD GHOST stands before you, immune to all weapons! Exits are NORTH, SOUTH, and EAST.",
		"items": [],
		"exits": {"n": "ghost3", "s": "immune_path1", "e": "immune_path2"}
	},
	"immune_path1": {
		"desc": "You cannot pass the immune ghost this way!",
		"items": [],
		"exits": {}
	},
	"immune_path2": {
		"desc": "A narrow passage. Exits are WEST and EAST.",
		"items": [],
		"exits": {"w": "head_ghost", "e": "drop_sword_room"}
	},
	"drop_sword_room": {
		"desc": "A room where the sword feels heavy. Exits are WEST and EAST.",
		"items": [],
		"exits": {"w": "immune_path2", "e": "past_immune1"}
	},
	"past_immune1": {
		"desc": "You've bypassed the immune ghost! Exits are WEST and SOUTH.",
		"items": [],
		"exits": {"w": "drop_sword_room", "s": "past_immune2"}
	},
	"past_immune2": {
		"desc": "Getting closer to freedom. Exits are NORTH and WEST.",
		"items": [],
		"exits": {"n": "past_immune1", "w": "sign_room"}
	},
	"sign_room": {
		"desc": "A room with a SIGN on the wall. Exits are SOUTH, EAST, and WEST.",
		"items": ["sign"],
		"exits": {"s": "final_exit", "e": "past_immune2", "w": "final_exit"}
	},
	"final_exit": {
		"desc": "You have escaped the haunted house! You WIN!",
		"items": [],
		"exits": {}
	}
}

func _ready():
	# Create UI
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)
	
	output_text = RichTextLabel.new()
	output_text.bbcode_enabled = true
	output_text.scroll_following = true
	output_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(output_text)
	
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var prompt = Label.new()
	prompt.text = ">"
	hbox.add_child(prompt)
	
	input_field = LineEdit.new()
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.text_submitted.connect(_on_command_entered)
	hbox.add_child(input_field)
	
	print_output("[b]HAUNTED HOUSE[/b]")
	print_output("A classic text adventure. Type commands like GET, DROP, READ, GO, KILL, etc.")
	print_output("")
	describe_room()
	input_field.grab_focus()

func _on_command_entered(command: String):

	if game_over:
		return
	
	print_output("> " + command)
	process_command(command.to_upper().strip_edges())
	input_field.clear()
	input_field.grab_focus()

func process_command(cmd: String):
	var parts = cmd.split(" ", false, 1)
	var verb = parts[0] if parts.size() > 0 else ""
	var noun = parts[1] if parts.size() > 1 else ""
	
	match verb:
		"GET", "TAKE":
			cmd_get(noun)
		"DROP":
			cmd_drop(noun)
		"READ":
			cmd_read(noun)
		"SAY":
			cmd_say(noun)
		"OPEN":
			cmd_open(noun)
		"GO":
			cmd_go(noun)
		"CLIMB":
			cmd_climb(noun)
		"KILL":
			cmd_kill(noun)
		"DRINK":
			cmd_drink(noun)
		"INVENTORY", "I":
			cmd_inventory()
		"N", "NORTH", "S", "SOUTH", "E", "EAST", "W", "WEST":
			cmd_move(verb[0].to_lower())
		"YES":
			cmd_yes()
		"ENTER":
			cmd_move("enter")
		_:
			print_output("I don't understand that command.")

func cmd_get(item: String):
	item = item.to_lower()
	if current_room == "trap_room" and item == "key":
		if not trapped:
			print_output("There is no key here.")
			return
	
	if item in rooms[current_room]["items"]:
		rooms[current_room]["items"].erase(item)
		inventory.append(item)
		print_output("Taken.")
	else:
		print_output("I don't see that here.")

func cmd_drop(item: String):
	item = item.to_lower()
	if item in inventory:
		inventory.erase(item)
		
		if item == "rope" and current_room == "rope_room":
			rope_dropped = true
			print_output("You drop the rope. It magically extends upward through the hole!")
		elif item == "sign" and current_room == "sign_room":
			rooms[current_room]["items"].append(item)
			print_output("Dropped.")
		else:
			rooms[current_room]["items"].append(item)
			print_output("Dropped.")
	else:
		print_output("You don't have that.")

func cmd_read(item: String):
	item = item.to_lower()
	if item in inventory or item in rooms[current_room]["items"]:
		match item:
			"paper":
				know_plugh = true
				print_output("The paper reads: 'Say PLUGH to enter the house.'")
			"scroll":
				print_output("The scroll reads: 'To escape the second floor, seek the sign of exit.'")
			"sword":
				print_output("The sword has ancient runes: 'Strike down the spirits that bar your way.'")
			"sign":
				print_output("The sign reads: 'DANGER - Do not carry this sign through the exit or you will fall to your death!'")
			_:
				print_output("There's nothing to read on that.")
	else:
		print_output("You don't see that here.")

func cmd_say(word: String):
	if word == "PLUGH" and current_room == "outside":
		if know_plugh:
			current_room = "entrance"
			print_output("A magical force transports you inside the house!")
			describe_room()
		else:
			print_output("Nothing happens.")
	else:
		print_output("Nothing happens.")

func cmd_open(item: String):
	if item.to_lower() == "cabinet" and current_room == "trap_room":
		if trapped:
			rooms[current_room]["items"].append("key")
			print_output("You open the cabinet and find a KEY inside!")
		else:
			print_output("The cabinet is stuck and won't open.")
	else:
		print_output("You can't open that.")

func cmd_go(direction: String):
	direction = direction.to_lower()
	if direction == "panel" and current_room == "panel_room":
		print_output("You go through the panel...")
		describe_room()
	else:
		cmd_move(direction)

func cmd_climb(item: String):
	if item.to_lower() == "rope" and current_room == "rope_room":
		if rope_dropped:
			current_room = "second_floor"
			print_output("You climb the rope to the second floor.")
			describe_room()
		else:
			print_output("There's no rope to climb!")
	else:
		print_output("You can't climb that.")

func cmd_kill(target: String):
	if target.to_lower() == "ghost":
		if "sword" in inventory:
			match current_room:
				"ghost1", "ghost2", "ghost3":
					ghosts_killed += 1
					print_output("You strike the ghost with your sword! It vanishes with a terrible shriek!")
					# Remove ghost blocking
				"head_ghost":
					print_output("The head ghost is immune to your sword! It laughs at your futile attempt.")
				_:
					print_output("There's no ghost here to kill.")
		else:
			print_output("You have no weapon!")
	else:
		print_output("You can't kill that.")

func cmd_drink(item: String):
	if item.to_lower() == "water":
		if "bucket" in inventory:
			print_output("You drink the water and immediately feel violently ill!")
			death("The water was poisoned!")
		else:
			print_output("You don't have any water.")
	else:
		print_output("You can't drink that.")

func cmd_inventory():
	if inventory.size() == 0:
		print_output("You are carrying nothing.")
	else:
		print_output("You are carrying: " + ", ".join(inventory).to_upper())

func cmd_move(direction: String):
	# Special trap room logic
	if current_room == "trap_room":
		if not trapped:
			if direction == "s":
				trap_counter += 1
				if trap_counter == 1:
					print_output("You move but something feels wrong...")
					describe_room()
					return
			elif direction == "n":
				trap_counter += 1
				if trap_counter == 2:
					trapped = true
					print_output("You're trapped! The room has sealed itself!")
					describe_room()
					return
			elif direction == "w" and "key" not in inventory:
				print_output("You can't seem to leave this way yet...")
				describe_room()
				return
		
		if trapped and "key" in inventory:
			# Exit sequence: E, S, W, N
			match exit_counter:
				0:
					if direction == "e":
						exit_counter = 1
						print_output("You move...")
						describe_room()
						return
				1:
					if direction == "s":
						exit_counter = 2
						print_output("You move...")
						describe_room()
						return
				2:
					if direction == "w":
						exit_counter = 3
						print_output("You move...")
						describe_room()
						return
				3:
					if direction == "n":
						current_room = "hallway2"
						trapped = false
						exit_counter = 0
						trap_counter = 0
						print_output("You've escaped the trap room!")
						describe_room()
						return
			
			print_output("You move but remain in the room...")
			describe_room()
			return
	
	# Panel room special navigation
	if current_room == "panel_room":
		if direction == "w":
			current_room = "locked_hallway"
			describe_room()
			return
	
	# Locked door check
	if current_room == "locked_hallway" and direction == "s":
		if "key" in inventory:
			passed_locked_door = true
			current_room = "spooky_room"
			describe_room()
			return
		else:
			print_output("The door is locked! You need a KEY.")
			return
	
	# Spooky room warning
	if current_room == "spooky_room" and direction == "e":
		print_output("Despite the warning, do you go EAST? (type YES or NO)")
		return
	
	# Ghost room checks
	if current_room in ["ghost1", "ghost2", "ghost3"] and ghosts_killed < ["ghost1", "ghost2", "ghost3"].find(current_room) + 1:
		print_output("The ghost blocks your path! You must KILL it first!")
		return
	
	# Head ghost bypass - can't go south with sword
	if current_room == "head_ghost" and direction == "s":
		if "sword" in inventory:
			print_output("The immune ghost blocks you while you carry the sword!")
			return
	
	# Sign room death trap
	if current_room == "sign_room" and direction in ["s", "e", "w"]:
		if "sign" in inventory:
			death("You fall through a trap door to your death! You shouldn't have carried the sign!")
			return
		else:
			current_room = "final_exit"
			print_output("YOU HAVE WON! Congratulations on escaping the HAUNTED HOUSE!")
			game_over = true
			return
	
	# Regular movement
	if direction in rooms[current_room]["exits"]:
		var next_room = rooms[current_room]["exits"][direction]
		
		if next_room == "death":
			death("You have died in the haunted house!")
			return
		
		current_room = next_room
		describe_room()
	else:
		print_output("You can't go that way.")

func cmd_yes():
	if current_room == "spooky_room":
		current_room = "rope_room"
		print_output("You bravely ignore the warning and proceed east.")
		describe_room()
	else:
		print_output("Yes to what?")

func describe_room():
	if game_over:
		return
	
	print_output("")
	print_output("[b]" + current_room.to_upper().replace("_", " ") + "[/b]")
	print_output(rooms[current_room]["desc"])
	
	if rooms[current_room]["items"].size() > 0:
		print_output("You can see: " + ", ".join(rooms[current_room]["items"]).to_upper())

func death(message: String):
	print_output("")
	print_output("[color=red]" + message + "[/color]")
	print_output("[b]GAME OVER[/b]")
	game_over = true

func print_output(text: String):
	print(text)
	output_text.append_text(text + "\n")
	
