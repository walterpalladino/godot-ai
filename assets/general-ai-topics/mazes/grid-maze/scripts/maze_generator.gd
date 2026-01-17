extends Node

# Maze configuration - MIN_DISTANCE now controls total maze rooms
const MIN_DISTANCE : int = 20
const GRID_WIDTH : int = 8  # Smaller grid for better visibility
const GRID_HEIGHT : int = 8
const DEAD_END_PROBABILITY : float = 0.3  # 30% chance to create dead ends

# Cell class to store maze data
class Cell:
	var coord_x : int
	var coord_y : int
	var visited : bool = false
	var walls : Dictionary = {
		"north": true,
		"south": true,
		"east": true,
		"west": true
	}
	
	func _init(x: int, y: int):
		coord_x = x
		coord_y = y

# Maze grid
var grid : Array = []
var start_cell : Vector2i
var end_cell : Vector2i
var shortest_path : Array = []
var total_rooms : int = 0

func _ready():
	print("=== MAZE GENERATOR WITH ROOM COUNT CONSTRAINT ===")
	print("Dead End Probability: ", int(DEAD_END_PROBABILITY * 100), "%")
	print("")
	generate_valid_maze()
	display_maze()
	print("")
	display_path_info()
	print("")
	analyze_dead_ends()
	print("")
	verify_traversal()

# Generate maze with exact room count
func generate_valid_maze():
	var attempts : int = 0
	
	while true:
		attempts += 1
		print("Generation attempt #", attempts)
		
		# Calculate grid size needed for MIN_DISTANCE rooms
		var calculated_width = ceili(sqrt(MIN_DISTANCE))
		var calculated_height = ceili(float(MIN_DISTANCE) / calculated_width)
		
		# Use the smaller of configured or calculated size
		var actual_width = min(GRID_WIDTH, calculated_width)
		var actual_height = min(GRID_HEIGHT, calculated_height)
		
		print("  -> Grid size: ", actual_width, "x", actual_height, " (max ", actual_width * actual_height, " rooms)")
		
		# Initialize grid
		initialize_grid(actual_width, actual_height)
		
		# Set start cell (random)
		start_cell = Vector2i(randi() % actual_width, randi() % actual_height)
		
		# Generate maze using DFS with room limit
		total_rooms = generate_maze_with_limit(start_cell.x, start_cell.y, MIN_DISTANCE)
		
		print("  -> Rooms generated: ", total_rooms)
		
		# Find the furthest reachable cell from start as end point
		end_cell = find_furthest_cell()
		
		# Compute shortest path
		shortest_path = compute_shortest_path()
		var distance = shortest_path.size()
		
		print("  -> Path length: ", distance, " cells")
		
		# Check if we have the desired number of rooms
		if total_rooms >= MIN_DISTANCE - 2 and total_rooms <= MIN_DISTANCE + 2:
			print("  -> SUCCESS! Generated ", total_rooms, " rooms (target: ", MIN_DISTANCE, ")")
			print("")
			break
		else:
			print("  -> Room count mismatch. Regenerating...")
			print("")

# Initialize the grid with all walls
func initialize_grid(width: int, height: int):
	grid.clear()
	for y in range(height):
		var row : Array = []
		for x in range(width):
			var cell = Cell.new(x, y)
			row.append(cell)
		grid.append(row)

# DFS maze generation with room count limit and dead ends
func generate_maze_with_limit(x: int, y: int, max_rooms: int) -> int:
	var stack : Array = []
	var rooms_created : int = 0
	
	stack.append(Vector2i(x, y))
	grid[y][x].visited = true
	rooms_created = 1
	
	while stack.size() > 0 and rooms_created < max_rooms:
		var current = stack.back()
		var current_cell = grid[current.y][current.x]
		
		# Get unvisited neighbors
		var directions = ["north", "south", "east", "west"]
		directions.shuffle()
		
		var found_neighbor = false
		
		for direction in directions:
			var neighbor_coords = get_neighbor_coordinates(current.x, current.y, direction)
			
			if neighbor_coords != Vector2i(-1, -1):
				var nx = neighbor_coords.x
				var ny = neighbor_coords.y
				var neighbor_cell = grid[ny][nx]
				
				if not neighbor_cell.visited and rooms_created < max_rooms:
					# Remove walls between current and neighbor
					remove_wall(current_cell, neighbor_cell, direction)
					
					# Mark as visited and add to stack
					neighbor_cell.visited = true
					stack.append(neighbor_coords)
					rooms_created += 1
					found_neighbor = true
					
					# Randomly decide to create a dead end (stop exploring this branch)
					if randf() < DEAD_END_PROBABILITY:
						# This creates a dead end - we don't continue from this cell
						stack.pop_back()
						found_neighbor = false  # Allow backtracking
					
					break
		
		# If no unvisited neighbor found, backtrack
		if not found_neighbor:
			stack.pop_back()
	
	return rooms_created

# Find the furthest cell from start
func find_furthest_cell() -> Vector2i:
	var queue : Array = []
	var visited_bfs : Dictionary = {}
	var distances : Dictionary = {}
	
	var start_key = Vector2i(start_cell.x, start_cell.y)
	queue.append(start_key)
	visited_bfs[start_key] = true
	distances[start_key] = 0
	
	var furthest_cell = start_key
	var max_distance = 0
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_distance = distances[current]
		
		if current_distance > max_distance:
			max_distance = current_distance
			furthest_cell = current
		
		# Check all four directions
		for direction in ["north", "south", "east", "west"]:
			var cell = grid[current.y][current.x]
			
			# Only traverse if wall is removed
			if not cell.walls[direction]:
				var neighbor = get_neighbor_coordinates(current.x, current.y, direction)
				
				if neighbor != Vector2i(-1, -1) and not visited_bfs.has(neighbor):
					visited_bfs[neighbor] = true
					distances[neighbor] = current_distance + 1
					queue.append(neighbor)
	
	return furthest_cell

# Get neighbor coordinates in a given direction
func get_neighbor_coordinates(x: int, y: int, direction: String) -> Vector2i:
	var grid_height = grid.size()
	var grid_width = grid[0].size() if grid_height > 0 else 0
	
	match direction:
		"north":
			if y > 0:
				return Vector2i(x, y - 1)
		"south":
			if y < grid_height - 1:
				return Vector2i(x, y + 1)
		"east":
			if x < grid_width - 1:
				return Vector2i(x + 1, y)
		"west":
			if x > 0:
				return Vector2i(x - 1, y)
	return Vector2i(-1, -1)

# Remove wall between two cells
func remove_wall(cell1: Cell, cell2: Cell, direction: String):
	match direction:
		"north":
			cell1.walls["north"] = false
			cell2.walls["south"] = false
		"south":
			cell1.walls["south"] = false
			cell2.walls["north"] = false
		"east":
			cell1.walls["east"] = false
			cell2.walls["west"] = false
		"west":
			cell1.walls["west"] = false
			cell2.walls["east"] = false

# BFS to find shortest path
func compute_shortest_path() -> Array:
	var queue : Array = []
	var visited_bfs : Dictionary = {}
	var parent : Dictionary = {}
	
	var start_key = Vector2i(start_cell.x, start_cell.y)
	queue.append(start_key)
	visited_bfs[start_key] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == end_cell:
			# Reconstruct path
			return reconstruct_path(parent, start_key, end_cell)
		
		# Check all four directions
		for direction in ["north", "south", "east", "west"]:
			var cell = grid[current.y][current.x]
			
			# Only traverse if wall is removed
			if not cell.walls[direction]:
				var neighbor = get_neighbor_coordinates(current.x, current.y, direction)
				
				if neighbor != Vector2i(-1, -1) and not visited_bfs.has(neighbor):
					visited_bfs[neighbor] = true
					parent[neighbor] = current
					queue.append(neighbor)
	
	return [] # No path found

# Reconstruct path from parent dictionary
func reconstruct_path(parent: Dictionary, start: Vector2i, goal: Vector2i) -> Array:
	var path : Array = []
	var current = goal
	
	while current != start:
		path.push_front(current)
		current = parent[current]
	
	path.push_front(start)
	return path

# Display the maze
func display_maze():
	var grid_height = grid.size()
	var grid_width = grid[0].size() if grid_height > 0 else 0
	
	print("GENERATED MAZE:")
	print("")
	
	# Top border
	print(create_separator("=", grid_width * 4 + 1))
	
	for y in range(grid_height):
		# Top walls
		var top_line = ""
		for x in range(grid_width):
			var cell = grid[y][x]
			top_line += "+"
			if cell.walls["north"]:
				top_line += "---"
			else:
				top_line += "   "
		top_line += "+"
		print(top_line)
		
		# Side walls and cell content
		var middle_line = ""
		for x in range(grid_width):
			var cell = grid[y][x]
			if cell.walls["west"]:
				middle_line += "|"
			else:
				middle_line += " "
			
			# Mark start, end, path, and visited cells
			var cell_pos = Vector2i(x, y)
			if cell_pos == start_cell:
				middle_line += " S "
			elif cell_pos == end_cell:
				middle_line += " E "
			elif cell_pos in shortest_path:
				middle_line += " * "
			elif cell.visited:
				middle_line += "   "
			else:
				middle_line += " # "  # Unvisited (shouldn't happen in valid maze)
		
		# Right border
		var last_cell = grid[y][grid_width - 1]
		if last_cell.walls["east"]:
			middle_line += "|"
		else:
			middle_line += " "
		print(middle_line)
	
	# Bottom border
	var bottom_line = ""
	for x in range(grid_width):
		var cell = grid[grid_height - 1][x]
		bottom_line += "+"
		if cell.walls["south"]:
			bottom_line += "---"
		else:
			bottom_line += "   "
	bottom_line += "+"
	print(bottom_line)
	
	print("")
	print("Legend: S=Start, E=End, *=Path, #=Unreachable")

# Display path information
func display_path_info():
	print("MAZE INFORMATION:")
	print(create_separator("-", 50))
	print("Target Room Count: ", MIN_DISTANCE, " rooms")
	print("Actual Room Count: ", total_rooms, " rooms")
	print("Grid Size: ", grid[0].size(), "x", grid.size())
	print("")
	print("Start: (", start_cell.x, ", ", start_cell.y, ")")
	print("End: (", end_cell.x, ", ", end_cell.y, ")")
	print("Shortest Path Length: ", shortest_path.size(), " cells")

# Verify maze can be traversed
func verify_traversal():
	print("TRAVERSAL VERIFICATION:")
	print(create_separator("-", 50))
	
	# Check if path exists
	if shortest_path.is_empty():
		print("ERROR: No path found between Start and End!")
		return
	
	# Verify path continuity
	var valid = true
	for i in range(shortest_path.size() - 1):
		var current = shortest_path[i]
		var next = shortest_path[i + 1]
		
		if not are_cells_connected(current, next):
			print("ERROR: Path broken between (", current.x, ", ", current.y, ") and (", next.x, ", ", next.y, ")")
			valid = false
			break
	
	if valid:
		print("SUCCESS: Maze is fully traversable!")
		print("Path verification: All ", shortest_path.size(), " cells are properly connected.")
		print("")
		print("Path coordinates:")
		var path_str = "  "
		for i in range(shortest_path.size()):
			var cell = shortest_path[i]
			path_str += "(" + str(cell.x) + "," + str(cell.y) + ")"
			if i < shortest_path.size() - 1:
				path_str += " -> "
		print(path_str)

# Check if two adjacent cells are connected (no wall between them)
func are_cells_connected(cell1: Vector2i, cell2: Vector2i) -> bool:
	var dx = cell2.x - cell1.x
	var dy = cell2.y - cell1.y
	
	var current_cell = grid[cell1.y][cell1.x]
	
	if dx == 1 and dy == 0:  # East
		return not current_cell.walls["east"]
	elif dx == -1 and dy == 0:  # West
		return not current_cell.walls["west"]
	elif dx == 0 and dy == 1:  # South
		return not current_cell.walls["south"]
	elif dx == 0 and dy == -1:  # North
		return not current_cell.walls["north"]
	
	return false

# Utility function to create separator
func create_separator(character: String, count: int) -> String:
	var line_data = ""
	for n in range(count):
		line_data += character
	return line_data

# Analyze and display dead ends in the maze
func analyze_dead_ends():
	print("DEAD END ANALYSIS:")
	print(create_separator("-", 50))
	
	var dead_ends : Array = []
	var grid_height = grid.size()
	var grid_width = grid[0].size() if grid_height > 0 else 0
	
	for y in range(grid_height):
		for x in range(grid_width):
			var cell = grid[y][x]
			if not cell.visited:
				continue
			
			# Count open passages (walls that are removed)
			var open_passages = 0
			for wall in cell.walls.values():
				if not wall:
					open_passages += 1
			
			# A dead end has only one open passage
			if open_passages == 1:
				dead_ends.append(Vector2i(x, y))
	
	print("Total dead ends found: ", dead_ends.size())
	
	if dead_ends.size() > 0:
		print("Dead end locations:")
		for dead_end in dead_ends:
			var is_start = (dead_end == start_cell)
			var is_end = (dead_end == end_cell)
			var marker = ""
			if is_start:
				marker = " [START]"
			elif is_end:
				marker = " [END]"
			print("  (", dead_end.x, ", ", dead_end.y, ")", marker)
	
	var dead_end_ratio = float(dead_ends.size()) / total_rooms * 100.0
	print("Dead end ratio: ", "%.1f" % dead_end_ratio, "%")
