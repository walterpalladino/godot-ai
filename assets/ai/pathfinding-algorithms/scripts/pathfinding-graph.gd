extends Node

class_name PathfindingGraph

# Node class to represent graph vertices
class PathfindingGraphNode:
	var id: Variant  # Can be String, int, Vector2, etc.
	var data: Dictionary  # Store any custom data
	
	func _init(node_id: Variant, node_data: Dictionary = {}):
		id = node_id
		data = node_data
	
	func _to_string() -> String:
		return str(id)

# Edge class to represent connections between nodes
class PathfindingGraphEdge:
	var from_node: Variant
	var to_node: Variant
	var weight: float
	
	func _init(from_id: Variant, to_id: Variant, edge_weight: float = 1.0):
		from_node = from_id
		to_node = to_id
		weight = edge_weight

# Grid cell class for grid-based pathfinding
class PathfindingGraphGridCell:
	var weight: float  # Movement cost through this cell
	var traversable_from: Dictionary  # Direction -> bool (can enter from this direction)
	var traversable_to: Dictionary  # Direction -> bool (can exit to this direction)
	
	func _init(cell_weight: float = 1.0):
		weight = cell_weight
		traversable_from = {}
		traversable_to = {}
	
	# Set if this cell can be entered from a direction
	func set_traversable_from(direction: Vector2i, value: bool) -> void:
		traversable_from[direction] = value
	
	# Set if this cell can be exited to a direction
	func set_traversable_to(direction: Vector2i, value: bool) -> void:
		traversable_to[direction] = value
	
	# Check if can move from this direction
	func can_enter_from(direction: Vector2i) -> bool:
		return traversable_from.get(direction, true)
	
	# Check if can move to this direction
	func can_exit_to(direction: Vector2i) -> bool:
		return traversable_to.get(direction, true)

# Graph structure
var nodes: Dictionary = {}  # node_id -> PathfindingGraphNode
var adjacency: Dictionary = {}  # node_id -> Array[PathfindingGraphEdge]

# Grid directions (4-way and 8-way movement)
const DIR_4 = [
	Vector2i(0, -1),   # North
	Vector2i(1, 0),    # East
	Vector2i(0, 1),    # South
	Vector2i(-1, 0)    # West
]

const DIR_8 = [
	Vector2i(0, -1),   # North
	Vector2i(1, -1),   # Northeast
	Vector2i(1, 0),    # East
	Vector2i(1, 1),    # Southeast
	Vector2i(0, 1),    # South
	Vector2i(-1, 1),   # Southwest
	Vector2i(-1, 0),   # West
	Vector2i(-1, -1)   # Northwest
]

# Add a node to the graph
func add_node(node_id: Variant, node_data: Dictionary = {}) -> PathfindingGraphNode:
	if nodes.has(node_id):
		push_warning("Node already exists: " + str(node_id))
		return nodes[node_id]
	
	var node = PathfindingGraphNode.new(node_id, node_data)
	nodes[node_id] = node
	adjacency[node_id] = []
	return node

# Add an edge between two nodes
func add_edge(from_id: Variant, to_id: Variant, weight: float = 1.0, bidirectional: bool = false) -> void:
	if not nodes.has(from_id):
		push_error("Source node does not exist: " + str(from_id))
		return
	
	if not nodes.has(to_id):
		push_error("Destination node does not exist: " + str(to_id))
		return
	
	var edge = PathfindingGraphEdge.new(from_id, to_id, weight)
	adjacency[from_id].append(edge)
	
	if bidirectional:
		var reverse_edge = PathfindingGraphEdge.new(to_id, from_id, weight)
		adjacency[to_id].append(reverse_edge)

# Remove a node from the graph
func remove_node(node_id: Variant) -> void:
	if not nodes.has(node_id):
		return
	
	nodes.erase(node_id)
	adjacency.erase(node_id)
	
	# Remove all edges pointing to this node
	for from_id in adjacency.keys():
		adjacency[from_id] = adjacency[from_id].filter(
			func(edge): return edge.to_node != node_id
		)

# Remove an edge
func remove_edge(from_id: Variant, to_id: Variant, bidirectional: bool = false) -> void:
	if adjacency.has(from_id):
		adjacency[from_id] = adjacency[from_id].filter(
			func(edge): return edge.to_node != to_id
		)
	
	if bidirectional and adjacency.has(to_id):
		adjacency[to_id] = adjacency[to_id].filter(
			func(edge): return edge.to_node != from_id
		)

# Get all neighbors of a node
func get_neighbors(node_id: Variant) -> Array:
	if not adjacency.has(node_id):
		return []
	return adjacency[node_id]

# Check if a node exists
func graph_has_node(node_id: Variant) -> bool:
	return nodes.has(node_id)

# Get node by ID
func graph_get_node(node_id: Variant) -> PathfindingGraphNode:
	return nodes.get(node_id, null)

# Clear the entire graph
func clear() -> void:
	nodes.clear()
	adjacency.clear()

# ============================================================================
# GRID TO GRAPH CONVERSION
# ============================================================================

# Convert a 2D grid into a graph
# grid: 2D array of GridCell objects or dictionaries with 'weight' and 'traversable' keys
# allow_diagonal: Enable 8-way movement instead of 4-way
# Returns: true if successful
func create_graph_from_grid(grid: Array, allow_diagonal: bool = false) -> bool:
	if grid.size() == 0:
		push_error("Grid is empty")
		return false
	
	clear()  # Clear existing graph
	
	var height = grid.size()
	var width = grid[0].size()
	
	var directions = DIR_8 if allow_diagonal else DIR_4
	
	# First pass: Create all nodes for traversable cells
	for y in range(height):
		for x in range(width):
			var cell = grid[y][x]
			#print(cell)
			# Skip null cells or non-traversable cells
			if cell == null:
				continue
			
			var cell_data = _parse_cell_data(cell)
			if cell_data == null || cell_data.is_empty():
				continue
			#print(cell_data)
			# Create node for this grid position
			var node_id = Vector2i(x, y)
			add_node(node_id, {
				"position": Vector2(x, y),
				"weight": cell_data.weight,
				"grid_cell": cell
			})
	
	# Second pass: Create edges between adjacent nodes
	for y in range(height):
		for x in range(width):
			var current_pos = Vector2i(x, y)
			
			# Skip if no node exists at this position
			if not graph_has_node(current_pos):
				continue
			
			var current_cell = grid[y][x]
			var current_data = _parse_cell_data(current_cell)
			
			# Check all possible directions
			for direction in directions:
				var neighbor_pos = current_pos + direction
				
				# Check if neighbor is within grid bounds
				if neighbor_pos.x < 0 or neighbor_pos.x >= width or \
				   neighbor_pos.y < 0 or neighbor_pos.y >= height:
					continue
				
				# Skip if no node exists at neighbor position
				if not graph_has_node(neighbor_pos):
					continue
				
				var neighbor_cell = grid[neighbor_pos.y][neighbor_pos.x]
				var neighbor_data = _parse_cell_data(neighbor_cell)
				
				if neighbor_data == null:
					continue
				
				# Check traversability rules
				var can_move = _can_traverse(
					current_cell, current_data,
					neighbor_cell, neighbor_data,
					direction
				)
				
				if can_move:
					# Calculate edge weight
					var edge_weight = _calculate_edge_weight(
						current_data.weight,
						neighbor_data.weight,
						direction,
						allow_diagonal
					)
					
					# Add directed edge
					add_edge(current_pos, neighbor_pos, edge_weight, false)
	
	return true

# Parse cell data from various formats
func _parse_cell_data(cell) -> Dictionary:
	if cell == null:
		return {}
	
	# If it's a GridCell object
	if cell is PathfindingGraphGridCell:
		return {
			"weight": cell.weight,
			"traversable_from": cell.traversable_from,
			"traversable_to": cell.traversable_to,
			"is_grid_cell": true
		}
	
	# If it's a Dictionary
	if cell is Dictionary:
		var weight = cell.get("weight", 1.0)
		var traversable = cell.get("traversable", true)
		
		# If not traversable at all, return null
		if not traversable:
			return {}
		
		return {
			"weight": weight,
			"traversable_from": cell.get("traversable_from", {}),
			"traversable_to": cell.get("traversable_to", {}),
			"is_grid_cell": false
		}
	
	# If it's a number (weight only)
	if cell is float or cell is int:
		if cell < 0:  # Negative weight means not traversable
			return {}
		return {
			"weight": float(cell),
			"traversable_from": {},
			"traversable_to": {},
			"is_grid_cell": false
		}
	
	return {}

# Check if movement between cells is allowed
func _can_traverse(from_cell, from_data: Dictionary, to_cell, to_data: Dictionary, direction: Vector2i) -> bool:
	# Check if from_cell allows exit in this direction
	if from_data.has("traversable_to") and from_data.traversable_to.size() > 0:
		if not from_data.traversable_to.get(direction, true):
			return false
	
	# Check if to_cell allows entry from opposite direction
	var opposite_dir = -direction
	if to_data.has("traversable_from") and to_data.traversable_from.size() > 0:
		if not to_data.traversable_from.get(opposite_dir, true):
			return false
	
	return true

# Calculate edge weight between two cells
func _calculate_edge_weight(from_weight: float, to_weight: float, direction: Vector2i, allow_diagonal: bool) -> float:
	# Base cost is average of both cells' weights
	var base_cost = (from_weight + to_weight) / 2.0
	
	# Diagonal movement costs more (approximately sqrt(2))
	if allow_diagonal and (direction.x != 0 and direction.y != 0):
		base_cost *= 1.414
	
	return base_cost

# ============================================================================
# PATHFINDING ALGORITHMS
# ============================================================================

# Dijkstra's algorithm implementation
func find_path(start_id: Variant, goal_id: Variant) -> Array:
	if not graph_has_node(start_id):
		push_error("Start node does not exist: " + str(start_id))
		return []
	
	if not graph_has_node(goal_id):
		push_error("Goal node does not exist: " + str(goal_id))
		return []
	
	var distances: Dictionary = {}
	var previous: Dictionary = {}
	var unvisited: Array = []
	
	for node_id in nodes.keys():
		distances[node_id] = INF
		unvisited.append(node_id)
	
	distances[start_id] = 0.0
	
	while unvisited.size() > 0:
		var current = _get_min_distance_node(unvisited, distances)
		
		if current == goal_id:
			break
		
		unvisited.erase(current)
		
		if distances[current] == INF:
			continue
		
		var edges = get_neighbors(current)
		for edge in edges:
			var neighbor_id = edge.to_node
			
			if not unvisited.has(neighbor_id):
				continue
			
			var alt_distance = distances[current] + edge.weight
			
			if alt_distance < distances[neighbor_id]:
				distances[neighbor_id] = alt_distance
				previous[neighbor_id] = current
	
	return _reconstruct_path(previous, start_id, goal_id)

# A* algorithm implementation (requires heuristic function)
func find_path_astar(start_id: Variant, goal_id: Variant, heuristic_func: Callable) -> Array:
	if not graph_has_node(start_id) or not graph_has_node(goal_id):
		push_error("Start or goal node does not exist")
		return []
	
	var g_score: Dictionary = {}
	var f_score: Dictionary = {}
	var previous: Dictionary = {}
	var open_set: Array = [start_id]
	
	for node_id in nodes.keys():
		g_score[node_id] = INF
		f_score[node_id] = INF
	
	g_score[start_id] = 0.0
	f_score[start_id] = heuristic_func.call(start_id, goal_id)
	
	while open_set.size() > 0:
		var current = _get_min_distance_node(open_set, f_score)
		
		if current == goal_id:
			return _reconstruct_path(previous, start_id, goal_id)
		
		open_set.erase(current)
		
		var edges = get_neighbors(current)
		for edge in edges:
			var neighbor_id = edge.to_node
			var tentative_g = g_score[current] + edge.weight
			
			if tentative_g < g_score[neighbor_id]:
				previous[neighbor_id] = current
				g_score[neighbor_id] = tentative_g
				f_score[neighbor_id] = g_score[neighbor_id] + heuristic_func.call(neighbor_id, goal_id)
				
				if not open_set.has(neighbor_id):
					open_set.append(neighbor_id)
	
	return []

# Helper function to find node with minimum distance
func _get_min_distance_node(node_list: Array, distances: Dictionary) -> Variant:
	var min_dist = INF
	var min_node = node_list[0]
	
	for node_id in node_list:
		if distances[node_id] < min_dist:
			min_dist = distances[node_id]
			min_node = node_id
	
	return min_node

# Reconstruct path from previous map
func _reconstruct_path(previous: Dictionary, start_id: Variant, goal_id: Variant) -> Array:
	var path: Array = []
	var current = goal_id
	
	if not previous.has(current) and current != start_id:
		return []
	
	while current != start_id:
		path.append(current)
		if not previous.has(current):
			return []
		current = previous[current]
	
	path.append(start_id)
	path.reverse()
	
	return path

# Get total path cost
func get_path_cost(path: Array) -> float:
	if path.size() < 2:
		return 0.0
	
	var total_cost = 0.0
	for i in range(path.size() - 1):
		var from_id = path[i]
		var to_id = path[i + 1]
		
		var edges = get_neighbors(from_id)
		for edge in edges:
			if edge.to_node == to_id:
				total_cost += edge.weight
				break
	
	return total_cost

# ============================================================================
# EXAMPLE USAGE
# ============================================================================

func _ready():
	example_usage()

func example_usage():
	print("=== Pathfinding Graph Examples ===\n")
	
	print("--- Example 1: City Road Network (Graph-based) ---")
	example_city_network()
	
	print("\n--- Example 2: Game Waypoints (Graph-based) ---")
	example_game_waypoints()
	
	print("\n--- Example 3: One-Way Streets (Graph-based) ---")
	example_one_way_streets()
	
	print("\n--- Example 4: Simple Grid ---")
	example_simple_grid()
	
	print("\n--- Example 5: Grid with Weights ---")
	example_weighted_grid()
	
	print("\n--- Example 6: One-Way Passages ---")
	example_one_way_grid()

func example_city_network():
	# Create a graph representing a city road network
	add_node("Home")
	add_node("Store")
	add_node("Park")
	add_node("School")
	add_node("Office")
	
	# Add roads (bidirectional with different weights for distances)
	add_edge("Home", "Store", 2.0, true)
	add_edge("Home", "Park", 5.0, true)
	add_edge("Store", "School", 3.0, true)
	add_edge("Park", "School", 2.0, true)
	add_edge("School", "Office", 4.0, true)
	add_edge("Store", "Office", 8.0, true)
	
	# Find shortest path
	var path = find_path("Home", "Office")
	
	if path.size() > 0:
		print("Path from Home to Office:")
		print("  Route: ", " -> ".join(path))
		print("  Total distance: ", get_path_cost(path), " km")
	else:
		print("No path found!")

func example_game_waypoints():
	clear()  # Clear previous graph
	
	# Create waypoint system with Vector2 positions
	var waypoints = {
		"spawn": Vector2(0, 0),
		"checkpoint1": Vector2(10, 5),
		"checkpoint2": Vector2(20, 5),
		"treasure": Vector2(15, 15),
		"exit": Vector2(25, 20)
	}
	
	# Add nodes with position data
	for wp_name in waypoints.keys():
		add_node(wp_name, {"position": waypoints[wp_name]})
	
	# Add connections with weights based on distance
	add_edge("spawn", "checkpoint1", 5.0, true)
	add_edge("checkpoint1", "checkpoint2", 7.0, true)
	add_edge("checkpoint1", "treasure", 12.0, true)
	add_edge("checkpoint2", "exit", 10.0, true)
	add_edge("treasure", "exit", 8.0, true)
	
	# Find path using Dijkstra
	var path = find_path("spawn", "exit")
	
	if path.size() > 0:
		print("Path from spawn to exit:")
		print("  Waypoints: ", path)
		print("  Total cost: ", get_path_cost(path))
		
		# Try A* with simple heuristic
		var heuristic = func(from_id, to_id):
			var from_pos = graph_get_node(from_id).data["position"]
			var to_pos = graph_get_node(to_id).data["position"]
			return from_pos.distance_to(to_pos) * 0.5  # Scale factor
		
		var astar_path = find_path_astar("spawn", "exit", heuristic)
		print("  A* path: ", astar_path)

func example_one_way_streets():
	clear()  # Clear previous graph
	
	# Create a city with one-way streets
	add_node("Home")
	add_node("MainStreet")
	add_node("Downtown")
	add_node("Highway")
	add_node("Office")
	add_node("ShoppingMall")
	
	# Regular two-way streets
	add_edge("Home", "MainStreet", 2.0, true)
	add_edge("ShoppingMall", "MainStreet", 3.0, true)
	
	# ONE-WAY street: MainStreet -> Downtown (but not back)
	add_edge("MainStreet", "Downtown", 4.0, false)  # Can go forward
	# No reverse edge, so cannot go Downtown -> MainStreet directly
	
	# ONE-WAY highway entrance: Downtown -> Highway (but not back)
	add_edge("Downtown", "Highway", 2.0, false)  # Can enter highway
	# Cannot exit highway back to Downtown
	
	# ONE-WAY highway exit: Highway -> Office (but not back)
	add_edge("Highway", "Office", 3.0, false)  # Can exit to Office
	# Cannot go back from Office to Highway
	
	# Alternative route: Office has a regular street back to ShoppingMall
	add_edge("Office", "ShoppingMall", 5.0, true)
	
	# Alternative slower route avoiding one-way streets
	add_edge("MainStreet", "ShoppingMall", 2.0, true)
	add_edge("ShoppingMall", "Office", 6.0, true)
	
	print("\n=== Forward Journey (Home to Office) ===")
	var path_forward = find_path("Home", "Office")
	
	if path_forward.size() > 0:
		print("Route: ", " -> ".join(path_forward))
		print("Distance: ", get_path_cost(path_forward), " km")
		print("(Uses one-way streets efficiently)")
	else:
		print("No path found!")
	
	print("\n=== Return Journey (Office to Home) ===")
	var path_back = find_path("Office", "Home")
	
	if path_back.size() > 0:
		print("Route: ", " -> ".join(path_back))
		print("Distance: ", get_path_cost(path_back), " km")
		print("(Must take alternative route - cannot use one-way streets backwards)")
	else:
		print("No path found!")
	
	print("\n=== Route Comparison ===")
	print("Forward cost: ", get_path_cost(path_forward), " km")
	print("Return cost: ", get_path_cost(path_back), " km")
	print("Difference: ", abs(get_path_cost(path_back) - get_path_cost(path_forward)), " km")

func example_simple_grid():
	# Simple 5x5 grid (1 = walkable, -1 = wall)
	var grid = [
		[1, 1, 1, 1, 1],
		[1, -1, -1, -1, 1],
		[1, 1, 1, -1, 1],
		[1, -1, 1, 1, 1],
		[1, 1, 1, 1, 1]
	]
	
	create_graph_from_grid(grid, false)
	
	var start = Vector2i(0, 0)
	var goal = Vector2i(4, 4)
	var path = find_path(start, goal)
	
	if path.size() > 0:
		print("Path found: ", path)
		print("Path cost: ", get_path_cost(path))
	else:
		print("No path found!")

func example_weighted_grid():
	# Grid with different terrain costs
	var grid = []
	for y in range(5):
		var row = []
		for x in range(5):
			row.append({"weight": 1.0 + (x + y) * 0.5, "traversable": true})
		grid.append(row)
	
	# Add a wall
	grid[2][2] = {"weight": 1.0, "traversable": false}
	
	create_graph_from_grid(grid, true)  # Allow diagonal movement
	
	var start = Vector2i(0, 0)
	var goal = Vector2i(4, 4)
	
	# Use A* with Manhattan distance heuristic
	var heuristic = func(from_id, to_id):
		return abs(to_id.x - from_id.x) + abs(to_id.y - from_id.y)
	
	var path = find_path_astar(start, goal, heuristic)
	
	if path.size() > 0:
		print("A* path: ", path)
		print("Path cost: ", get_path_cost(path))

func example_one_way_grid():
	# Grid with one-way passages using GridCell objects
	var grid = []
	for y in range(4):
		var row = []
		for x in range(4):
			var cell = PathfindingGraphGridCell.new(1.0)
			row.append(cell)
		grid.append(row)
	
	# Create a one-way door at position (2, 1)
	# Can enter from left, but cannot exit back left
	var one_way_cell = grid[1][2]
	one_way_cell.set_traversable_from(Vector2i(-1, 0), true)   # Can enter from left
	one_way_cell.set_traversable_to(Vector2i(-1, 0), false)    # Cannot exit to left
	
	create_graph_from_grid(grid, false)
	
	# Try to go through the one-way passage
	var path_forward = find_path(Vector2i(0, 1), Vector2i(3, 1))
	print("Forward path (through one-way): ", path_forward)
	
	# Try to go back through the one-way passage (should find alternate route)
	var path_backward = find_path(Vector2i(3, 1), Vector2i(0, 1))
	print("Backward path (avoiding one-way): ", path_backward)
	
