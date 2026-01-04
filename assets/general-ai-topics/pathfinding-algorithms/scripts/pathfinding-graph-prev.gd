extends Node

class_name PathfindingGraphPrev

# Node class to represent graph vertices
class PathfindingGraphPrevNode:
	var id: Variant  # Can be String, int, Vector2, etc.
	var data: Dictionary  # Store any custom data
	
	func _init(node_id: Variant, node_data: Dictionary = {}):
		id = node_id
		data = node_data
	
	func _to_string() -> String:
		return str(id)

# Edge class to represent connections between nodes
class PathfindingGraphPrevEdge:
	var from_node: Variant
	var to_node: Variant
	var weight: float
	
	func _init(from_id: Variant, to_id: Variant, edge_weight: float = 1.0):
		from_node = from_id
		to_node = to_id
		weight = edge_weight

# Graph structure
var nodes: Dictionary = {}  # node_id -> PathfindingGraphNode
var adjacency: Dictionary = {}  # node_id -> Array[PathfindingGraphEdge]

# Add a node to the graph
func add_node(node_id: Variant, node_data: Dictionary = {}) -> PathfindingGraphPrevNode:
	if nodes.has(node_id):
		push_warning("Node already exists: " + str(node_id))
		return nodes[node_id]
	
	var node = PathfindingGraphPrevNode.new(node_id, node_data)
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
	
	var edge = PathfindingGraphPrevEdge.new(from_id, to_id, weight)
	adjacency[from_id].append(edge)
	
	if bidirectional:
		var reverse_edge = PathfindingGraphPrevEdge.new(to_id, from_id, weight)
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
#func get_neighbors(node_id: Variant) -> Array[PathfindingGraphEdge]:
func get_neighbors(node_id: Variant) -> Array:
	if not adjacency.has(node_id):
		return []
	#print(adjacency[node_id])
	return adjacency[node_id]

# Check if a node exists
func graph_has_node(node_id: Variant) -> bool:
	return nodes.has(node_id)

# Get node by ID
func graph_get_node(node_id: Variant) -> PathfindingGraphPrevNode:
	return nodes.get(node_id, null)

# Clear the entire graph
func clear() -> void:
	nodes.clear()
	adjacency.clear()

# Dijkstra's algorithm implementation
func find_path(start_id: Variant, goal_id: Variant) -> Array:
	if not graph_has_node(start_id):
		push_error("Start node does not exist: " + str(start_id))
		return []
	
	if not graph_has_node(goal_id):
		push_error("Goal node does not exist: " + str(goal_id))
		return []
	
	# Distance map: stores minimum distance to each node
	var distances: Dictionary = {}
	# Previous map: stores the previous node in the shortest path
	var previous: Dictionary = {}
	# Unvisited nodes
	var unvisited: Array = []
	
	# Initialize distances
	for node_id in nodes.keys():
		distances[node_id] = INF
		unvisited.append(node_id)
	
	distances[start_id] = 0.0
	
	while unvisited.size() > 0:
		# Find unvisited node with minimum distance
		var current = _get_min_distance_node(unvisited, distances)
		
		if current == goal_id:
			break
		
		unvisited.erase(current)
		
		# Skip if unreachable
		if distances[current] == INF:
			continue
		
		# Check all neighbors
		var edges = get_neighbors(current)
		for edge in edges:
			var neighbor_id = edge.to_node
			
			if not unvisited.has(neighbor_id):
				continue
			
			# Calculate tentative distance
			var alt_distance = distances[current] + edge.weight
			
			if alt_distance < distances[neighbor_id]:
				distances[neighbor_id] = alt_distance
				previous[neighbor_id] = current
	
	# Reconstruct path
	return _reconstruct_path(previous, start_id, goal_id)

# A* algorithm implementation (requires heuristic function)
func find_path_astar(start_id: Variant, goal_id: Variant, heuristic_func: Callable) -> Array:
	if not graph_has_node(start_id) or not graph_has_node(goal_id):
		push_error("Start or goal node does not exist")
		return []
	
	var g_score: Dictionary = {}  # Cost from start to node
	var f_score: Dictionary = {}  # Estimated total cost
	var previous: Dictionary = {}
	var open_set: Array = [start_id]
	
	# Initialize scores
	for node_id in nodes.keys():
		g_score[node_id] = INF
		f_score[node_id] = INF
	
	g_score[start_id] = 0.0
	f_score[start_id] = heuristic_func.call(start_id, goal_id)
	
	while open_set.size() > 0:
		# Get node with lowest f_score
		var current = _get_min_distance_node(open_set, f_score)
		
		if current == goal_id:
			return _reconstruct_path(previous, start_id, goal_id)
		
		open_set.erase(current)
		
		# Check neighbors
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
	
	return []  # No path found

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
		return []  # No path found
	
	while current != start_id:
		path.append(current)
		if not previous.has(current):
			return []  # Path broken
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
	print("=== General Graph Pathfinding Example ===\n")
	
	# Example 1: City road network
	print("--- Example 1: City Road Network ---")
	example_city_network()
	
	print("\n--- Example 2: Game Level Waypoints ---")
	example_game_waypoints()

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
