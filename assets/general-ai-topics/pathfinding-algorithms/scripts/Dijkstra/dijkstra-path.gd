## DijkstraPath.gd
class_name DijkstraPath
extends RefCounted

var cells: Array[DijkstraCell] = []
var total_weight: float = 0.0

func add_cell(cell: DijkstraCell) -> void:
	cells.append(cell)

func calculate_total_weight() -> void:
	total_weight = 0.0
	# Skip the first cell (starting position) as we're already there
	for i in range(1, cells.size()):
		total_weight += cells[i].weight
		
func get_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for cell in cells:
		positions.append(cell.position)
	return positions

func is_valid() -> bool:
	return cells.size() > 0

func _to_string() -> String:
	var result = "Path (total weight: %.2f):\n" % total_weight
	for i in cells.size():
		result += "  %d. %s\n" % [i, cells[i]]
	return result
	
