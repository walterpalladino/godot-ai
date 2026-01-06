## DijkstraPathfinder.gd
class_name DijkstraPathfinder
extends RefCounted

class _PathNode:
	var position: Vector2i
	var cost: float
	var parent: _PathNode
	
	func _init(pos: Vector2i, c: float, p: _PathNode = null) -> void:
		position = pos
		cost = c
		parent = p

var grid: DijkstraGrid
var allow_diagonal: bool = false

# Direction vectors for movement
const ORTHOGONAL_DIRS = [
	Vector2i(1, 0),   # Right
	Vector2i(-1, 0),  # Left
	Vector2i(0, 1),   # Down
	Vector2i(0, -1)   # Up
]

const DIAGONAL_DIRS = [
	Vector2i(1, 1),   # Down-Right
	Vector2i(1, -1),  # Up-Right
	Vector2i(-1, 1),  # Down-Left
	Vector2i(-1, -1)  # Up-Left
]

func _init(g: DijkstraGrid, diagonal: bool = false) -> void:
	grid = g
	allow_diagonal = diagonal

func find_path(start: Vector2i, goal: Vector2i) -> DijkstraPath:
	if not grid.is_traversable(start) or not grid.is_traversable(goal):
		return DijkstraPath.new() # Return empty path
	
	if start == goal:
		var path = DijkstraPath.new()
		path.add_cell(grid.get_cell(start))
		path.calculate_total_weight()
		return path
	
	var open_set: Array[_PathNode] = []
	var closed_set: Dictionary = {} # Vector2i -> bool
	var costs: Dictionary = {} # Vector2i -> float
	
	var start_node = _PathNode.new(start, 0.0)
	open_set.append(start_node)
	costs[start] = 0.0
	
	while open_set.size() > 0:
		# Find node with lowest cost
		var current = _get_lowest_cost_node(open_set)
		open_set.erase(current)
		
		if current.position == goal:
			return _reconstruct_path(current)
		
		closed_set[current.position] = true
		
		# Check neighbors
		var neighbors = _get_neighbors(current.position)
		for neighbor_pos in neighbors:
			if closed_set.has(neighbor_pos):
				continue
			
			var neighbor_cell = grid.get_cell(neighbor_pos)
			if not neighbor_cell.is_traversable:
				continue
			
			var new_cost = current.cost + neighbor_cell.weight
			
			if not costs.has(neighbor_pos) or new_cost < costs[neighbor_pos]:
				costs[neighbor_pos] = new_cost
				var neighbor_node = _PathNode.new(neighbor_pos, new_cost, current)
				
				# Remove old node with same position if exists
				for i in range(open_set.size() - 1, -1, -1):
					if open_set[i].position == neighbor_pos:
						open_set.remove_at(i)
						break
				
				open_set.append(neighbor_node)
	
	return DijkstraPath.new() # No path found

func _get_lowest_cost_node(nodes: Array[_PathNode]) -> _PathNode:
	var lowest = nodes[0]
	for node in nodes:
		if node.cost < lowest.cost:
			lowest = node
	return lowest

func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = ORTHOGONAL_DIRS.duplicate()
	
	if allow_diagonal:
		directions.append_array(DIAGONAL_DIRS)
	
	for dir in directions:
		var neighbor_pos = pos + dir
		if grid.is_valid_position(neighbor_pos):
			neighbors.append(neighbor_pos)
	
	return neighbors

func _reconstruct_path(end_node: _PathNode) -> DijkstraPath:
	var path = DijkstraPath.new()
	var current = end_node
	var cells_reverse: Array[DijkstraCell] = []
	
	while current != null:
		cells_reverse.append(grid.get_cell(current.position))
		current = current.parent
	
	# Reverse to get path from start to goal
	for i in range(cells_reverse.size() - 1, -1, -1):
		path.add_cell(cells_reverse[i])
	
	path.calculate_total_weight()
	return path
	
