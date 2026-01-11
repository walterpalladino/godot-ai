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
	

func check_los(from_position: Vector2i, max_distance: float) -> Array[AStarGridCell]:
	var visible_cells: Array[AStarGridCell] = []
	
	if not is_valid_position(from_position):
		return visible_cells
	
	var max_dist_sq = max_distance * max_distance
	
	# Check all cells within the bounding box
	var min_x = max(0, int(from_position.x - max_distance))
	var max_x = min(width - 1, int(from_position.x + max_distance))
	var min_y = max(0, int(from_position.y - max_distance))
	var max_y = min(height - 1, int(from_position.y + max_distance))
	
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var target_pos = Vector2i(x, y)
			
			# Skip the starting position
			if target_pos == from_position:
				continue
			
			# Check if within max distance
			var dx = target_pos.x - from_position.x
			var dy = target_pos.y - from_position.y
			var dist_sq = dx * dx + dy * dy
			
			if dist_sq > max_dist_sq:
				continue
			
			# Perform line of sight check using Bresenham's line algorithm
			if has_line_of_sight(from_position, target_pos):
				var cell = get_cell(target_pos)
				if cell:
					visible_cells.append(cell)
	
	return visible_cells

func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var x = from.x
	var y = from.y
	var step_x = 1 if to.x > from.x else -1
	var step_y = 1 if to.y > from.y else -1
	
	if dx > dy:
		var error = dx / 2.0
		while x != to.x:
			x += step_x
			error -= dy
			if error < 0:
				y += step_y
				error += dx
			
			# Check if current position is blocked
			var current_pos = Vector2i(x, y)
			if current_pos != to:  # Don't check the target itself
				var cell = get_cell(current_pos)
				if not cell or not cell.is_traversable():
					return false
	else:
		var error = dy / 2.0
		while y != to.y:
			y += step_y
			error -= dx
			if error < 0:
				x += step_x
				error += dy
			
			# Check if current position is blocked
			var current_pos = Vector2i(x, y)
			if current_pos != to:  # Don't check the target itself
				var cell = get_cell(current_pos)
				if not cell or not cell.is_traversable():
					return false
	
	return true

func check_movement(from_position: Vector2i, max_movement: float) -> Array[AStarGridCell]:
	var reachable_cells: Array[AStarGridCell] = []
	
	if not is_valid_position(from_position):
		return reachable_cells
	
	var start_cell = get_cell(from_position)
	if not start_cell or not start_cell.is_traversable():
		return reachable_cells
	
	# Use Dijkstra's algorithm to find all reachable cells within movement range
	var visited: Dictionary = {}
	var cost_so_far: Dictionary = {from_position: 0.0}
	var frontier: Array = [from_position]
	
	while frontier.size() > 0:
		# Get the position with lowest cost
		var current = frontier[0]
		var lowest_cost = cost_so_far.get(current, INF)
		var lowest_index = 0
		
		for i in range(1, frontier.size()):
			var pos = frontier[i]
			var cost = cost_so_far.get(pos, INF)
			if cost < lowest_cost:
				current = pos
				lowest_cost = cost
				lowest_index = i
		
		frontier.remove_at(lowest_index)
		
		if visited.has(current):
			continue
		
		visited[current] = true
		
		# Add this cell to reachable cells (except starting position)
		if current != from_position:
			var cell = get_cell(current)
			if cell:
				reachable_cells.append(cell)
		
		# Explore neighbors
		for neighbor_pos in get_neighbors(current):
			if visited.has(neighbor_pos):
				continue
			
			var neighbor_cell = get_cell(neighbor_pos)
			if not neighbor_cell or not neighbor_cell.is_traversable():
				continue
			
			var new_cost = cost_so_far[current] + neighbor_cell.weight
			
			# Only add if within movement range
			if new_cost <= max_movement:
				if not cost_so_far.has(neighbor_pos) or new_cost < cost_so_far[neighbor_pos]:
					cost_so_far[neighbor_pos] = new_cost
					if not frontier.has(neighbor_pos):
						frontier.append(neighbor_pos)
	
	return reachable_cells
