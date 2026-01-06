class_name AStarGridCell
extends RefCounted

var position: Vector2i
var weight: float

func _init(pos: Vector2i, w: float = 1.0):
	position = pos
	weight = w

func is_traversable() -> bool:
	return weight >= 0
