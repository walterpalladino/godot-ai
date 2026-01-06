## DijkstraCell.gd
class_name DijkstraCell
extends RefCounted

var position: Vector2i
var weight: float
var is_traversable: bool

func _init(pos: Vector2i, w: float) -> void:
	position = pos
	weight = w
	is_traversable = (weight >= 0)

func _to_string() -> String:
	return "Cell(%s, weight: %.1f)" % [position, weight]
	
	
