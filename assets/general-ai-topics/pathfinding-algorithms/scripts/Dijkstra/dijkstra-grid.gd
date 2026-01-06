## DijkstraGrid.gd
class_name DijkstraGrid
extends RefCounted

var cells: Dictionary = {} # Vector2i -> DijkstraCell
var width: int
var height: int

func _init(w: int, h: int) -> void:
	width = w
	height = h

func set_cell(pos: Vector2i, weight: float) -> void:
	cells[pos] = DijkstraCell.new(pos, weight)

func get_cell(pos: Vector2i) -> DijkstraCell:
	return cells.get(pos)

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func is_traversable(pos: Vector2i) -> bool:
	var cell = get_cell(pos)
	return cell != null and cell.is_traversable
	
