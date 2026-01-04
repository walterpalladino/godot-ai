extends Node

class_name PathfindingGraphGrid

# Grid cell class to store traversal data
class GridCell:
	var position: Vector2i
	var weight: float
	var is_traversable: bool
	
	func _init(pos: Vector2i, w: float = 1.0, traversable: bool = true):
		position = pos
		weight = w
		is_traversable = traversable

# Graph structure
var grid: Array[Array] = []
var width: int = 0
var height: int = 0

# Diagonal movement setting
var allow_diagonal: bool = false
var diagonal_cost_multiplier: float = 1.414  # sqrt(2) for realistic diagonal distance

# Initialize grid from 2D array data
func create_grid_from_data(grid_data: Array) -> void:
	height = grid_data.size()
	if height == 0:
		push_error("Grid data is empty")
		return
	
	width = grid_data[0].size()
	grid.clear()
	
	for y in range(height):
		var row: Array[GridCell] = []
		for x in range(width):
			var cell_data = grid_data[y][x]
			var cell = GridCell.new(
				Vector2i(x, y),
				cell_data.get("weight", 1.0),
				cell_data.get("traversable", true)
			)
			row.append(cell)
		grid.append(row)

# Set whether diagonal movement is allowed
func set_allow_diagonal(enabled: bool) -> void:
	allow_diagonal = enabled

# Set the cost multiplier for diagonal movement
func set_diagonal_cost_multiplier(multiplier: float) -> void:
	diagonal_cost_multiplier = multiplier

# Get neighbors of a cell (4-directional or 8-directional)
func get_neighbors(pos: Vector2i) -> Array[GridCell]:
	var neighbors: Array[GridCell] = []
	
	# Cardinal directions (always available)
	var cardinal_directions = [
		Vector2i(0, -1),  # Up
		Vector2i(1, 0),   # Right
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0)   # Left
	]
	
	# Diagonal directions (optional)
	var diagonal_directions = [
		Vector2i(1, -1),  # Up-Right
		Vector2i(1, 1),   # Down-Right
		Vector2i(-1, 1),  # Down-Left
		Vector2i(-1, -1)  # Up-Left
	]
	
	# Add cardinal neighbors
	for dir in cardinal_directions:
		var new_pos = pos + dir
		if is_valid_position(new_pos):
			var cell = grid[new_pos.y][new_pos.x]
			if cell.is_traversable:
				neighbors.append(cell)
	
	# Add diagonal neighbors if enabled
	if allow_diagonal:
		for dir in diagonal_directions:
			var new_pos = pos + dir
			if is_valid_position(new_pos):
				var cell = grid[new_pos.y][new_pos.x]
				if cell.is_traversable:
					# Check if diagonal movement is blocked by adjacent walls
					if _is_diagonal_passable(pos, dir):
						neighbors.append(cell)
	
	return neighbors

# Check if diagonal movement is blocked by adjacent walls
func _is_diagonal_passable(pos: Vector2i, diagonal_dir: Vector2i) -> bool:
	# Check the two cardinal cells adjacent to the diagonal
	var horizontal_pos = pos + Vector2i(diagonal_dir.x, 0)
	var vertical_pos = pos + Vector2i(0, diagonal_dir.y)
	
	# Both adjacent cells must be traversable to allow diagonal movement
	var horizontal_clear = true
	var vertical_clear = true
	
	if is_valid_position(horizontal_pos):
		horizontal_clear = grid[horizontal_pos.y][horizontal_pos.x].is_traversable
	else:
		horizontal_clear = false
	
	if is_valid_position(vertical_pos):
		vertical_clear = grid[vertical_pos.y][vertical_pos.x].is_traversable
	else:
		vertical_clear = false
	
	return horizontal_clear and vertical_clear

# Check if position is within grid bounds
func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

# Calculate movement cost based on direction
func _get_movement_cost(from: Vector2i, to: Vector2i, cell_weight: float) -> float:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	# Check if movement is diagonal
	if dx == 1 and dy == 1:
		return cell_weight * diagonal_cost_multiplier
	else:
		return cell_weight

# Dijkstra's algorithm implementation
func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	if not is_valid_position(start) or not is_valid_position(goal):
		push_error("Start or goal position is out of bounds")
		return []
	
	if not grid[start.y][start.x].is_traversable or not grid[goal.y][goal.x].is_traversable:
		push_error("Start or goal position is not traversable")
		return []
	
	# Distance map: stores minimum distance to each cell
	var distances: Dictionary = {}
	# Previous map: stores the previous cell in the shortest path
	var previous: Dictionary = {}
	# Priority queue (using array with manual sorting for simplicity)
	var unvisited: Array[Vector2i] = []
	
	# Initialize distances
	for y in range(height):
		for x in range(width):
			var pos = Vector2i(x, y)
			distances[pos] = INF
			unvisited.append(pos)
	
	distances[start] = 0.0
	
	while unvisited.size() > 0:
		# Find unvisited cell with minimum distance
		var current = _get_min_distance_cell(unvisited, distances)
		
		if current == goal:
			break
		
		unvisited.erase(current)
		
		# Skip if unreachable
		if distances[current] == INF:
			continue
		
		# Check all neighbors
		var neighbors = get_neighbors(current)
		for neighbor in neighbors:
			if not unvisited.has(neighbor.position):
				continue
			
			# Calculate tentative distance with diagonal cost consideration
			var movement_cost = _get_movement_cost(current, neighbor.position, neighbor.weight)
			var alt_distance = distances[current] + movement_cost
			
			if alt_distance < distances[neighbor.position]:
				distances[neighbor.position] = alt_distance
				previous[neighbor.position] = current
	
	# Reconstruct path
	return _reconstruct_path(previous, start, goal)

# Helper function to find cell with minimum distance
func _get_min_distance_cell(cells: Array[Vector2i], distances: Dictionary) -> Vector2i:
	var min_dist = INF
	var min_cell = cells[0]
	
	for cell in cells:
		if distances[cell] < min_dist:
			min_dist = distances[cell]
			min_cell = cell
	
	return min_cell

# Reconstruct path from previous map
func _reconstruct_path(previous: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = goal
	
	if not previous.has(current) and current != start:
		return []  # No path found
	
	while current != start:
		path.append(current)
		if not previous.has(current):
			return []  # Path broken
		current = previous[current]
	
	path.append(start)
	path.reverse()
	
	return path

# ============================================================================
# EXAMPLE USAGE
# ============================================================================

func _ready():
	example_usage()

func example_usage():
	print("=== Dijkstra's Pathfinding Example ===\n")
	
	# Create a 5x5 grid with various weights and obstacles
	var grid_data = [
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 5.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 0.0, "traversable": false},
			{"weight": 0.0, "traversable": false},
			{"weight": 0.0, "traversable": false},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 2.0, "traversable": true},
			{"weight": 2.0, "traversable": true},
			{"weight": 0.0, "traversable": false},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		]
	]
	
	create_grid_from_data(grid_data)
	
	var start_pos = Vector2i(0, 0)
	var goal_pos = Vector2i(4, 4)
	
	# Test WITHOUT diagonal movement
	print("--- WITHOUT Diagonal Movement ---")
	set_allow_diagonal(false)
	var path_no_diag = find_path(start_pos, goal_pos)
	
	if path_no_diag.size() > 0:
		print("Path found with ", path_no_diag.size(), " steps:")
		for step in path_no_diag:
			print("  -> ", step)
		print("\nGrid visualization:")
		_visualize_grid(path_no_diag, start_pos, goal_pos)
	else:
		print("No path found!")
	
	print("\n" + "=".repeat(50) + "\n")
	
	# Test WITH diagonal movement
	print("--- WITH Diagonal Movement ---")
	set_allow_diagonal(true)
	var path_with_diag = find_path(start_pos, goal_pos)
	
	if path_with_diag.size() > 0:
		print("Path found with ", path_with_diag.size(), " steps:")
		for step in path_with_diag:
			print("  -> ", step)
		print("\nGrid visualization:")
		_visualize_grid(path_with_diag, start_pos, goal_pos)
	else:
		print("No path found!")

# Helper function to visualize the grid in console
func _visualize_grid(path: Array[Vector2i], start: Vector2i, goal: Vector2i):
	for y in range(height):
		var line = ""
		for x in range(width):
			var pos = Vector2i(x, y)
			var cell = grid[y][x]
			
			if pos == start:
				line += "S "
			elif pos == goal:
				line += "G "
			elif not cell.is_traversable:
				line += "# "
			elif path.has(pos):
				line += "* "
			else:
				line += ". "
		print(line)
