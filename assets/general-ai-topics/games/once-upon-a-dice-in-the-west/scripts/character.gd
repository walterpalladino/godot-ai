# ============================================
# FILE: res://character.gd
# Create this as a new GDScript file
# ============================================

class_name WesternCharacter
extends Object
# 
 
var character_name = ""
var character_type = "Normal"
var weapon = "revolver"
var player_num = 1
var wounds = 0
var status = "active"
var moved_this_turn = false
var moved_last_turn = false
var on_guard = false
var aimed = false
var immobilized = false
var position = Vector2.ZERO

func initialize(name: String, type: String, weap: String, player: int, pos: Vector2):
	character_name = name
	character_type = type
	weapon = weap
	player_num = player
	position = pos
