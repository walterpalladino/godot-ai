class_name AStarPathResult
extends RefCounted

var cells: Array[AStarGridCell] = []
var total_weight: float = 0.0
var success: bool = false

func add_cell(cell: AStarGridCell) -> void:
	cells.append(cell)
	if cell.weight >= 0:
		total_weight += cell.weight

func get_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for cell in cells:
		positions.append(cell.position)
	return positions
