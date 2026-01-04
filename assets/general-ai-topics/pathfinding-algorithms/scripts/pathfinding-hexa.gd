extends Node

#Key Particularities Documented in Code:
#
#Hexagon Orientation: FLAT-TOP
#
#Hexagons have flat edges on top/bottom and pointy sides left/right
#This is the "odd-r horizontal layout"
#
#
#Offset System
#
#ODD-numbered ROWS (1, 3, 5...) are shifted RIGHT by half a hex width
#Even rows (0, 2, 4...) are not offset
#
#
#Neighbor Directions
#
#The 6 neighbors are: East, Southeast, Southwest, West, Northwest, Northeast
#Direction offsets change based on whether you're on an odd or even row
#Odd rows: neighbors shifted right relative to even rows
#
#
#Coordinate System
#
#X = column (increases right)
#Y = row (increases down)
#Position stored as Vector2i(column, row)
#
#
#Visualization
#
#Odd rows are indented with a space to show the rightward offset visually in the console
#
#
#
#This is the standard layout used in many hex-based games and matches well with Godot's TileMap when configured for flat-top hexagons!


class_name PathfindingHexa

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

# Initialize hexagonal grid from 2D array data
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

# Get neighbors of a hexagonal cell (6-directional)
func get_neighbors(pos: Vector2i) -> Array[GridCell]:
	var neighbors: Array[GridCell] = []
	var directions = _get_hex_neighbors_offset(pos)
	
	for dir in directions:
		var new_pos = pos + dir
		if is_valid_position(new_pos):
			var cell = grid[new_pos.y][new_pos.x]
			if cell.is_traversable:
				neighbors.append(cell)
	
	return neighbors

# Get hexagonal neighbors using axial coordinates converted from offset
# This provides more accurate hexagonal distance calculations
func _get_hex_neighbors_offset(pos: Vector2i) -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	var col = pos.x
	var row = pos.y
	
	# For odd columns (offset down in odd-q vertical layout)
	if col % 2 == 1:
		directions = [
			Vector2i(0, -1),   # North
			Vector2i(1, 0),    # Northeast
			Vector2i(1, 1),    # Southeast
			Vector2i(0, 1),    # South
			Vector2i(-1, 1),   # Southwest
			Vector2i(-1, 0)    # Northwest
		]
	else:
		# For even columns
		directions = [
			Vector2i(0, -1),   # North
			Vector2i(1, -1),   # Northeast
			Vector2i(1, 0),    # Southeast
			Vector2i(0, 1),    # South
			Vector2i(-1, 0),   # Southwest
			Vector2i(-1, -1)   # Northwest
		]
	
	return directions

# Check if position is within grid bounds
func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

# Dijkstra's algorithm implementation for hexagonal grids
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
	# Priority queue (using array with manual sorting)
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
		
		# Check all hexagonal neighbors (6 directions)
		var neighbors = get_neighbors(current)
		for neighbor in neighbors:
			if not unvisited.has(neighbor.position):
				continue
			
			# Calculate tentative distance
			var alt_distance = distances[current] + neighbor.weight
			
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
	example_hexagonal_usage()

func example_hexagonal_usage():
	print("=== Dijkstra's Pathfinding for Hexagonal Grids ===\n")
	
	# Create a 7x6 hexagonal grid with obstacles and varying weights
	# Dictionary format: {"weight": float, "traversable": bool}
	var hex_grid_data = [
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 0.0, "traversable": false},  # Obstacle
			{"weight": 0.0, "traversable": false},  # Obstacle
			{"weight": 5.0, "traversable": true},   # High weight (difficult terrain)
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 0.0, "traversable": false},  # Obstacle
			{"weight": 1.0, "traversable": true},
			{"weight": 0.0, "traversable": false},  # Obstacle
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 2.0, "traversable": true},   # Medium weight
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 2.0, "traversable": true},   # Medium weight
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 0.0, "traversable": false},  # Obstacle
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		],
		[
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true},
			{"weight": 1.0, "traversable": true}
		]
	]
	
	# Initialize the hexagonal grid
	create_grid_from_data(hex_grid_data)
	
	# Find path from top-left to bottom-right
	var start_pos = Vector2i(0, 0)
	var goal_pos = Vector2i(6, 5)
	
	print("Finding path from ", start_pos, " to ", goal_pos)
	print("Using hexagonal grid with 6-directional movement (odd-q layout)")
	var path = find_path(start_pos, goal_pos)
	
	if path.size() > 0:
		print("\nPath found with ", path.size(), " steps:")
		print("Total cost: ", _calculate_path_cost(path))
		for i in range(path.size()):
			var step = path[i]
			var cell = grid[step.y][step.x]
			print("  Step ", i, ": ", step, " (weight: ", cell.weight, ")")
		
		# Visualize the hexagonal grid
		print("\nHexagonal grid visualization:")
		print("S=start, G=goal, #=obstacle, *=path")
		print("Numbers show terrain weight, .=normal terrain\n")
		_visualize_hex_grid(path, start_pos, goal_pos)
	else:
		print("No path found!")

# Calculate total path cost
func _calculate_path_cost(path: Array[Vector2i]) -> float:
	var total_cost = 0.0
	for pos in path:
		if pos != path[0]:  # Skip start position
			total_cost += grid[pos.y][pos.x].weight
	return total_cost

# Helper function to visualize the hexagonal grid in console
func _visualize_hex_grid(path: Array[Vector2i], start: Vector2i, goal: Vector2i):
	var header = "   "
	for x in range(width):
		header += str(x) + " "
	print(header)
	
	for y in range(height):
		var line = str(y) + "  "
		
		# Add offset for odd columns to simulate hex layout
		for x in range(width):
			if x % 2 == 1 and y == 0:
				line = " " + line
				break
		
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
				# Show weight if greater than 1
				if cell.weight > 1.0:
					line += str(int(cell.weight)) + " "
				else:
					line += ". "
		print(line)
