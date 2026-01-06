class_name AStarPathfinding
extends RefCounted

var grid: Array[Array] = []
var width: int = 0
var height: int = 0
var allow_diagonal: bool = false
var heuristic_func: Callable

func _init(grid_data: Array[Array], diagonal_movement: bool = false, custom_heuristic: Callable = Callable()):
	grid = grid_data
	height = grid.size()
	width = grid[0].size() if height > 0 else 0
	allow_diagonal = diagonal_movement
	
	if custom_heuristic.is_valid():
		heuristic_func = custom_heuristic
	else:
		heuristic_func = heuristic

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func get_cell(pos: Vector2i) -> AStarGridCell:
	if is_valid_position(pos):
		return grid[pos.y][pos.x]
	return null

func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(1, 0),   # Right
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0)   # Left
	]
	
	if allow_diagonal:
		directions.append_array([
			Vector2i(1, -1),  # Up-Right
			Vector2i(1, 1),   # Down-Right
			Vector2i(-1, 1),  # Down-Left
			Vector2i(-1, -1)  # Up-Left
		])
	
	for dir in directions:
		var neighbor_pos = pos + dir
		if is_valid_position(neighbor_pos):
			var cell = get_cell(neighbor_pos)
			if cell and cell.is_traversable():
				neighbors.append(neighbor_pos)
	
	return neighbors

func find_path(start: Vector2i, goal: Vector2i) -> AStarPathResult:
	var result = AStarPathResult.new()
	
	if not is_valid_position(start) or not is_valid_position(goal):
		return result
	
	var start_cell = get_cell(start)
	var goal_cell = get_cell(goal)
	
	if not start_cell or not goal_cell or not start_cell.is_traversable() or not goal_cell.is_traversable():
		return result
	
	var open_set: Array[Vector2i] = [start]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {start: 0.0}
	var f_score: Dictionary = {start: heuristic_func.call(start, goal)}
	
	while open_set.size() > 0:
		var current = get_lowest_f_score(open_set, f_score)
		
		if current == goal:
			result = reconstruct_path(came_from, current)
			result.success = true
			return result
		
		open_set.erase(current)
		
		for neighbor in get_neighbors(current):
			var neighbor_cell = get_cell(neighbor)
			var tentative_g = g_score[current] + neighbor_cell.weight
			
			if not g_score.has(neighbor) or tentative_g < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic_func.call(neighbor, goal)
				
				if not open_set.has(neighbor):
					open_set.append(neighbor)
	
	return result

func get_lowest_f_score(open_set: Array[Vector2i], f_score: Dictionary) -> Vector2i:
	var lowest = open_set[0]
	var lowest_score = f_score.get(lowest, INF)
	
	for pos in open_set:
		var score = f_score.get(pos, INF)
		if score < lowest_score:
			lowest = pos
			lowest_score = score
	
	return lowest

func reconstruct_path(came_from: Dictionary, current: Vector2i) -> AStarPathResult:
	var result = AStarPathResult.new()
	var path: Array[Vector2i] = [current]
	
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	
	for pos in path:
		var cell = get_cell(pos)
		result.add_cell(cell)
	
	return result
	
