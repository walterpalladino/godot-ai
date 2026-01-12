# ============================================
# PROJECT STRUCTURE:
# ============================================
# Create these files in your Godot 4 project:
# 
# res://main.tscn (Main scene)
# res://main.gd (This script - attach to root node)
# res://character.gd (Character class)
#
# ============================================

# ============================================
# FILE: res://main.gd
# Attach this to the root Node2D in main.tscn
# ============================================

extends Node2D

# Game state
enum GameState {SETUP, ROLLING_INITIATIVE, ACTIVATING, GAME_OVER}
var game_state = GameState.SETUP

# Players
var player1_characters = []
var player2_characters = []
var current_player = 1
var initiative = {1: 0, 2: 0}

# Activation
var selected_character = null
var action_points = 2
var activated_characters = []
var turn_number = 1
var round_number = 1

# Weapon data
var weapons = {
	"revolver": {"short_range": 6, "long_range": 12, "name": "Revolver"},
	"rifle": {"short_range": 12, "long_range": 24, "name": "Rifle"},
	"bow": {"short_range": 12, "long_range": 24, "name": "Bow & Arrow"},
	"spear": {"short_range": 6, "long_range": 12, "name": "Spear"}
}

var character_types = ["Normal", "Gunfighter", "Gunslinger", "Leader"]

# Character class definition
#var Character = preload("res://character.gd")
var Character = preload("res://assets/general-ai-topics/games/once-upon-a-dice-in-the-west/scripts/character.gd")


# Game speed
var action_delay = 1.0  # seconds between actions

func _ready():
	randomize()
	print("=================================================")
	print("    ONCE UPON A DICE IN THE WEST")
	print("    Automated AI Battle Simulation")
	print("=================================================")
	print("")
	
	# Start game automatically
	await get_tree().create_timer(1.0).timeout
	setup_game(5, 5)

func setup_game(p1_count, p2_count):
	print("GAME SETUP")
	print("--------------------------------------------------")
	
	player1_characters.clear()
	player2_characters.clear()
	
	# Create Player 1 characters
	print("")
	print("PLAYER 1 POSSE:")
	var special_count_p1 = 0
	for i in range(p1_count):
		var type = "Normal"
		if special_count_p1 < 2 and randf() < 0.4:
			type = character_types[randi() % 3 + 1]
			special_count_p1 += 1
		
		var weapon = weapons.keys()[randi() % weapons.size()]
		var char = create_character(i, "Cowboy %d" % (i + 1), type, weapon, 1)
		player1_characters.append(char)
		print("  - %s (%s with %s)" % [char.character_name, char.character_type, weapons[char.weapon].name])
	
	# Create Player 2 characters
	print("")
	print("PLAYER 2 POSSE:")
	var special_count_p2 = 0
	for i in range(p2_count):
		var type = "Normal"
		if special_count_p2 < 2 and randf() < 0.4:
			type = character_types[randi() % 3 + 1]
			special_count_p2 += 1
		
		var weapon = weapons.keys()[randi() % weapons.size()]
		var char = create_character(i, "Outlaw %d" % (i + 1), type, weapon, 2)
		player2_characters.append(char)
		print("  - %s (%s with %s)" % [char.character_name, char.character_type, weapons[char.weapon].name])
	
	print("")
	print("==================================================")
	print("")
	
	game_state = GameState.ROLLING_INITIATIVE
	await get_tree().create_timer(action_delay).timeout
	roll_initiative()

func create_character(id, char_name, type, weapon, player_num):
	var char = Character.new()
	
	# Position characters on opposite sides
	var x_pos = 100 + randi() % 200 if player_num == 1 else 900 + randi() % 200
	var y_pos = 100 + randi() % 400
	
	char.initialize(char_name, type, weapon, player_num, Vector2(x_pos, y_pos))
	return char

func roll_initiative():
	print("")
	print(">>> ROUND " + str(round_number) + " - ROLLING INITIATIVE <<<")
	print("--------------------------------------------------")
	
	initiative[1] = randi() % 6 + 1
	initiative[2] = randi() % 6 + 1
	
	print("Player 1 rolled: " + str(initiative[1]))
	print("Player 2 rolled: " + str(initiative[2]))
	
	if initiative[1] > initiative[2]:
		current_player = 1
		print("→ Player 1 wins initiative and goes first!")
	elif initiative[2] > initiative[1]:
		current_player = 2
		print("→ Player 2 wins initiative and goes first!")
	else:
		print("→ TIE! Rerolling...")
		await get_tree().create_timer(action_delay).timeout
		roll_initiative()
		return
	
	print("")
	
	game_state = GameState.ACTIVATING
	activated_characters.clear()
	reset_character_turn_status()
	
	await get_tree().create_timer(action_delay).timeout
	start_activation_phase()

func reset_character_turn_status():
	for char in player1_characters + player2_characters:
		char.moved_this_turn = false
		char.on_guard = false
		char.aimed = false
		char.moved_last_turn = char.moved_this_turn
		
		# Recover from dazed
		if char.status == "dazed":
			char.status = "active"
			print("  ✓ %s recovers from being dazed" % char.character_name)

func start_activation_phase():
	if game_state == GameState.GAME_OVER:
		return
	
	var current_chars = get_current_player_characters()
	
	# Find next character to activate
	var available_chars = []
	for char in current_chars:
		if char not in activated_characters:
			available_chars.append(char)
	
	if available_chars.size() == 0:
		# All characters activated, end round
		end_round()
		return
	
	# AI selects a character
	selected_character = available_chars[randi() % available_chars.size()]
	action_points = 2
	
	print("")
	print("[PLAYER " + str(current_player) + " ACTIVATES: " + selected_character.character_name + "]")
	print("  Type: " + selected_character.character_type + " | Weapon: " + weapons[selected_character.weapon].name + " | Wounds: " + str(selected_character.wounds) + " | Status: " + selected_character.status)
	
	await get_tree().create_timer(action_delay * 0.5).timeout
	ai_take_actions()

func ai_take_actions():
	if game_state == GameState.GAME_OVER:
		return
	
	while action_points > 0:
		if selected_character.immobilized:
			print("  → %s is immobilized and cannot act" % selected_character.character_name)
			break
		
		var action = ai_choose_action()
		
		match action:
			"move":
				var continue_turn = await perform_move()
				if not continue_turn:
					return
			"shoot":
				var continue_turn = await perform_shoot()
				if not continue_turn:
					return
			"aim":
				perform_aim()
			"guard":
				perform_guard()
				break
			"melee":
				await attempt_melee()
				break
			"end":
				break
		
		if action_points <= 0:
			break
		
		await get_tree().create_timer(action_delay * 0.3).timeout
	
	end_activation()

func ai_choose_action():
	var enemy_chars = get_opponent_characters()
	
	if enemy_chars.size() == 0:
		return "end"
	
	# Find closest enemy
	var closest_enemy = null
	var closest_distance = 999999
	
	for enemy in enemy_chars:
		var dist = selected_character.position.distance_to(enemy.position) / 10
		if dist < closest_distance:
			closest_distance = dist
			closest_enemy = enemy
	
	# Decision making
	var weapon_data = weapons[selected_character.weapon]
	
	# Check if in melee range
	if closest_distance <= 1:
		return "melee"
	
	# Check if in shooting range
	if closest_distance <= weapon_data.long_range:
		# If not aimed and have 2 AP, aim first
		if action_points >= 2 and not selected_character.aimed and randf() < 0.4:
			return "aim"
		return "shoot"
	
	# Move closer
	if action_points > 0:
		return "move"
	
	return "end"

func perform_move():
	if not selected_character or action_points < 1:
		return false
	
	print("  → Action: MOVE")
	
	var move_roll = randi() % 6 + 1
	print("    Movement roll: " + str(move_roll))
	
	# Check for activation failure
	if move_roll == 1:
		print("    ⚠ ROLLED 1! Can only move 1 inch. Turn ends!")
		
		# Move 1 inch toward closest enemy
		var enemy_chars = get_opponent_characters()
		if enemy_chars.size() > 0:
			var target = enemy_chars[0]
			var direction = (target.position - selected_character.position).normalized()
			selected_character.position += direction * 10
		
		await get_tree().create_timer(action_delay).timeout
		end_turn()
		return false
	
	# Calculate movement
	var move_distance = move_roll * 10  # 10 pixels = 1 inch
	
	# Apply wound modifier
	if selected_character.wounds >= 1:
		move_distance *= 0.5
		print("    Half speed due to wounds: " + str(int(move_distance / 10)) + " inches")
	
	# Move toward closest enemy
	var enemy_chars = get_opponent_characters()
	if enemy_chars.size() > 0:
		var target = enemy_chars[0]
		var direction = (target.position - selected_character.position).normalized()
		var new_pos = selected_character.position + direction * move_distance
		
		# Keep within bounds
		new_pos.x = clamp(new_pos.x, 50, 1200)
		new_pos.y = clamp(new_pos.y, 50, 600)
		
		selected_character.position = new_pos
		selected_character.moved_this_turn = true
		
		print("    Moved " + str(int(move_distance / 10)) + " inches toward enemy")
	
	action_points -= 1
	print("    Remaining AP: " + str(action_points))
	
	await get_tree().create_timer(action_delay * 0.5).timeout
	return true

func perform_shoot():
	if not selected_character or action_points < 1:
		return false
	
	print("  → Action: SHOOT")
	
	# Find target
	var enemy_chars = get_opponent_characters()
	if enemy_chars.size() == 0:
		print("    No targets available!")
		action_points -= 1
		return true
	
	# Select closest enemy in range
	var target = null
	var weapon_data = weapons[selected_character.weapon]
	
	for enemy in enemy_chars:
		var dist = selected_character.position.distance_to(enemy.position) / 10
		if dist <= weapon_data.long_range:
			target = enemy
			break
	
	if target == null:
		print("    No enemies in range!")
		action_points -= 1
		return true
	
	var shoot_result = await shoot_at_target(target)
	return shoot_result

func shoot_at_target(target):
	var shoot_roll = randi() % 6 + 1
	
	print("    Shooting roll: " + str(shoot_roll))
	
	# Check for activation failure
	if shoot_roll == 1 and not selected_character.moved_this_turn:
		print("    ⚠ ROLLED 1! Turn ends!")
		await get_tree().create_timer(action_delay).timeout
		end_turn()
		return false
	
	# Calculate distance
	var distance = selected_character.position.distance_to(target.position) / 10
	var weapon_data = weapons[selected_character.weapon]
	
	print("    Target: " + target.character_name + " (" + str(snappedf(distance, 0.1)) + " inches away)")
	
	# Check range
	if distance > weapon_data.long_range:
		print("    ✗ Out of range!")
		action_points -= 1
		return true
	
	var is_short_range = distance <= weapon_data.short_range
	print("    Range: " + ("SHORT" if is_short_range else "LONG"))
	
	# Roll to hit
	var hit_roll = randi() % 6 + 1
	var modifiers = 0
	var mod_text = []
	
	# Apply modifiers
	if target.moved_this_turn or target.moved_last_turn:
		modifiers -= 1
		mod_text.append("-1 target moved")
	
	if selected_character.aimed:
		modifiers += 1
		mod_text.append("+1 aimed")
		selected_character.aimed = false
	
	if selected_character.character_type in ["Gunfighter", "Gunslinger", "Leader"]:
		modifiers += 1
		mod_text.append("+1 special")
	
	if selected_character.wounds >= 2:
		modifiers -= 1
		mod_text.append("-1 wounded")
	
	var final_roll = hit_roll + modifiers
	var threshold = 5 if not is_short_range else 4
	
	print("    To-hit roll: " + str(hit_roll))
	if mod_text.size() > 0:
		print("    Modifiers: " + ", ".join(mod_text))
	print("    Final: " + str(final_roll) + " (need " + str(threshold) + "+)")
	
	if final_roll >= threshold:
		print("    ✓ HIT!")
		await apply_hit(target)
	else:
		print("    ✗ MISS!")
	
	action_points -= 1
	print("    Remaining AP: " + str(action_points))
	
	await get_tree().create_timer(action_delay * 0.5).timeout
	return true

func apply_hit(target):
	var hit_result = randi() % 6 + 1
	
	# Special character modifier
	if target.character_type in ["Gunfighter", "Gunslinger", "Leader"]:
		hit_result -= 1
		print("      Damage roll: " + str(hit_result + 1) + "-1 (special) = " + str(hit_result))
	else:
		print("      Damage roll: " + str(hit_result))
	
	if hit_result <= 2:
		# Dazed
		target.status = "dazed"
		print("      → %s is DAZED!" % target.character_name)
	elif hit_result <= 4:
		# Wounded
		target.wounds += 1
		target.status = "wounded"
		print("      → " + target.character_name + " is WOUNDED! (Total: " + str(target.wounds) + ")")
		
		# Check for effects
		if target.wounds >= 3:
			target.immobilized = true
			print("      → %s is IMMOBILIZED!" % target.character_name)
		
		if target.wounds >= 4:
			if target.character_type == "Normal":
				await kill_character(target)
			else:
				print("      → %s is critically wounded!" % target.character_name)
		
		if target.wounds >= 5 and target.character_type in ["Gunfighter", "Gunslinger", "Leader"]:
			await kill_character(target)
	else:
		# Killed
		await kill_character(target)
	
	await get_tree().create_timer(action_delay * 0.5).timeout

func kill_character(character):
	print("      ☠ " + character.character_name + " is KILLED!")
	
	if character in player1_characters:
		player1_characters.erase(character)
	elif character in player2_characters:
		player2_characters.erase(character)
	
	await get_tree().create_timer(action_delay * 0.5).timeout
	check_victory()

func check_victory():
	if player1_characters.size() == 0:
		print("")
		print("==================================================")
		print("🎯 PLAYER 2 WINS! 🎯")
		print("All Player 1 characters eliminated!")
		print("==================================================")
		game_state = GameState.GAME_OVER
	elif player2_characters.size() == 0:
		print("")
		print("==================================================")
		print("🎯 PLAYER 1 WINS! 🎯")
		print("All Player 2 characters eliminated!")
		print("==================================================")
		game_state = GameState.GAME_OVER

func perform_aim():
	if not selected_character or action_points < 1:
		return
	
	print("  → Action: AIM")
	selected_character.aimed = true
	print("    %s takes careful aim (+1 to next shot)" % selected_character.character_name)
	action_points -= 1
	print("    Remaining AP: " + str(action_points))

func perform_guard():
	if not selected_character:
		return
	
	print("  → Action: GO ON GUARD")
	selected_character.on_guard = true
	print("    %s is ready to react" % selected_character.character_name)
	action_points = 0

func attempt_melee():
	if not selected_character:
		return
	
	print("  → Action: MELEE ATTACK")
	
	# Find nearby enemies
	var nearby_enemies = []
	var enemy_list = get_opponent_characters()
	
	for enemy in enemy_list:
		var distance = selected_character.position.distance_to(enemy.position) / 10
		if distance <= 1:
			nearby_enemies.append(enemy)
	
	if nearby_enemies.size() == 0:
		print("    No enemies within melee range!")
		action_points = 0
		return
	
	var enemy = nearby_enemies[0]
	await perform_melee_combat(selected_character, enemy)
	action_points = 0

func perform_melee_combat(attacker, defender):
	print("    ⚔ MELEE: %s vs %s" % [attacker.character_name, defender.character_name])
	
	# Roll for attacker
	var attacker_roll = randi() % 6 + 1
	var attacker_mod = 0
	var att_mods = []
	
	if attacker.weapon in ["revolver", "spear"]:
		attacker_mod += 1
		att_mods.append("+1 weapon")
	if attacker.character_type in ["Gunfighter", "Gunslinger", "Leader"]:
		attacker_mod += 1
		att_mods.append("+1 special")
	if attacker.wounds > 0 or attacker.status == "dazed":
		attacker_mod -= 1
		att_mods.append("-1 wounded/dazed")
	
	var attacker_total = attacker_roll + attacker_mod
	
	# Roll for defender
	var defender_roll = randi() % 6 + 1
	var defender_mod = 0
	var def_mods = []
	
	if defender.weapon in ["revolver", "spear"]:
		defender_mod += 1
		def_mods.append("+1 weapon")
	if defender.character_type in ["Gunfighter", "Gunslinger", "Leader"]:
		defender_mod += 1
		def_mods.append("+1 special")
	if defender.wounds > 0 or defender.status == "dazed":
		defender_mod -= 1
		def_mods.append("-1 wounded/dazed")
	
	var defender_total = defender_roll + defender_mod
	
	print("      " + attacker.character_name + ": " + str(attacker_roll) + 
		(" [" + ", ".join(att_mods) + "]" if att_mods.size() > 0 else "") + " = " + str(attacker_total))
	print("      " + defender.character_name + ": " + str(defender_roll) +
		(" [" + ", ".join(def_mods) + "]" if def_mods.size() > 0 else "") + " = " + str(defender_total))
	
	await get_tree().create_timer(action_delay * 0.5).timeout
	
	if attacker_total > defender_total:
		print("      → %s wins the melee!" % attacker.character_name)
		await kill_character(defender)
	elif defender_total > attacker_total:
		print("      → %s wins the melee!" % defender.character_name)
		await kill_character(attacker)
	else:
		print("      → TIE! Fight continues...")

func get_current_player_characters():
	return player1_characters if current_player == 1 else player2_characters

func get_opponent_characters():
	return player2_characters if current_player == 1 else player1_characters

func end_activation():
	if selected_character:
		activated_characters.append(selected_character)
	
	print("  [End of " + selected_character.character_name + "'s activation]")
	print("")
	
	selected_character = null
	action_points = 2
	
	await get_tree().create_timer(action_delay).timeout
	
	# Check if all characters have activated
	var all_chars = player1_characters + player2_characters
	if activated_characters.size() >= all_chars.size():
		end_round()
	else:
		start_activation_phase()

func end_turn():
	print("  [Turn passes to Player " + str(3 - current_player) + "]")
	print("")
	
	# Switch to other player
	current_player = 3 - current_player
	selected_character = null
	action_points = 2
	
	await get_tree().create_timer(action_delay).timeout
	
	# Check if all characters have activated
	var all_chars = player1_characters + player2_characters
	if activated_characters.size() >= all_chars.size():
		end_round()
	else:
		start_activation_phase()

func end_round():
	print("")
	print("==================================================")
	print("END OF ROUND " + str(round_number))
	print("  Player 1: " + str(player1_characters.size()) + " characters remaining")
	print("  Player 2: " + str(player2_characters.size()) + " characters remaining")
	print("==================================================")
	print("")
	
	round_number += 1
	
	await get_tree().create_timer(action_delay * 1.5).timeout
	
	if game_state != GameState.GAME_OVER:
		roll_initiative()
		
