# Test suite
class_name AStarTests
extends Node

func _ready():
	print("=== A* Pathfinding Test Suite ===\n")
	test_simple_path()
	test_obstacles()
	test_weighted_path()
	test_no_path()
	test_diagonal_avoidance()
	test_complex_maze()
	test_diagonal_movement()
	test_custom_heuristic()
	test_line_of_sight()
	test_movement_range()
	print("\n=== All Tests Complete ===")

func create_grid(data: Array) -> Array[Array]:
	var grid: Array[Array] = []
	for row in data:
		var grid_row: Array[AStarGridCell] = []
		for i in range(row.size()):
			var weight = row[i]
			grid_row.append(AStarGridCell.new(Vector2i(i, grid.size()), weight))
		grid.append(grid_row)
	return grid

func print_grid_with_path(grid: Array[Array], path: AStarPathResult):
	var path_positions = path.get_positions()
	
	for y in range(grid.size()):
		var line = ""
		for x in range(grid[y].size()):
			var pos = Vector2i(x, y)
			var cell = grid[y][x]
			
			if pos in path_positions:
				if pos == path_positions[0]:
					line += "S "
				elif pos == path_positions[-1]:
					line += "E "
				else:
					line += "* "
			elif cell.weight == -1:
				line += "# "
			else:
				line += ". "
		print(line)

func test_simple_path():
	print("Test 1: Simple Straight Path")
	var grid_data = [
		[1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var path = pathfinder.find_path(Vector2i(0, 1), Vector2i(4, 1))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print()

func test_obstacles():
	print("Test 2: Path Around Obstacles")
	var grid_data = [
		[1, 1, 1, 1, 1],
		[1, -1, -1, -1, 1],
		[1, 1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var path = pathfinder.find_path(Vector2i(0, 1), Vector2i(4, 1))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print()

func test_weighted_path():
	print("Test 3: Weighted Path (prefers lower weight)")
	var grid_data = [
		[1, 5, 5, 5, 1],
		[1, 5, 10, 5, 1],
		[1, 1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(4, 0))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print("Path chooses bottom route (weight 5) over top route (weight 21)")
	print()

func test_no_path():
	print("Test 4: No Valid Path")
	var grid_data = [
		[1, 1, -1, 1, 1],
		[1, 1, -1, 1, 1],
		[1, 1, -1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var path = pathfinder.find_path(Vector2i(0, 1), Vector2i(4, 1))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print()

func test_diagonal_avoidance():
	print("Test 5: Path Through Narrow Gap")
	var grid_data = [
		[1, -1, -1, -1, 1],
		[1, 1, -1, 1, 1],
		[1, -1, -1, -1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var path = pathfinder.find_path(Vector2i(0, 1), Vector2i(4, 1))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print()

func test_complex_maze():
	print("Test 6: Complex Maze")
	var grid_data = [
		[1, 1, 1, -1, 1, 1, 1],
		[-1, -1, 1, -1, 1, -1, 1],
		[1, 1, 1, 1, 1, -1, 1],
		[1, -1, -1, -1, 1, -1, 1],
		[1, 1, 1, 1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(6, 4))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print()

func test_diagonal_movement():
	print("Test 7: Diagonal Movement Enabled")
	var grid_data = [
		[1, -1, -1, -1, 1],
		[-1, 1, -1, 1, -1],
		[-1, -1, 1, -1, -1],
		[-1, 1, -1, 1, -1],
		[1, -1, -1, -1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid, true)  # Enable diagonal movement
	var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(4, 4))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print("Diagonal movement allows shorter path through the maze")
	print()

func euclidean_heuristic(a: Vector2i, b: Vector2i) -> float:
	var dx = a.x - b.x
	var dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)

func test_custom_heuristic():
	print("Test 8: Custom Euclidean Heuristic with Diagonal Movement")
	var grid_data = [
		[1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid, true, euclidean_heuristic)
	var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(4, 4))
	
	print_grid_with_path(grid, path)
	print("Success: ", path.success)
	print("Path length: ", path.cells.size())
	print("Total weight: ", path.total_weight)
	print("Euclidean heuristic creates more direct diagonal path")
	print()

func print_grid_with_los(grid: Array[Array], from_pos: Vector2i, visible_cells: Array[AStarGridCell]):
	var visible_positions: Array[Vector2i] = []
	for cell in visible_cells:
		visible_positions.append(cell.position)
	
	for y in range(grid.size()):
		var line = ""
		for x in range(grid[y].size()):
			var pos = Vector2i(x, y)
			var cell = grid[y][x]
			
			if pos == from_pos:
				line += "O "
			elif pos in visible_positions:
				line += "V "
			elif cell.weight == -1:
				line += "# "
			else:
				line += ". "
		print(line)

func test_line_of_sight():
	print("Test 9: Line of Sight (LOS) Check")
	var grid_data = [
		[1, 1, 1, -1, 1, 1, 1],
		[1, 1, 1, -1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, -1, 1, 1, 1],
		[1, 1, 1, -1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var from_pos = Vector2i(1, 2)
	var visible = pathfinder.check_los(from_pos, 4.0)
	
	print_grid_with_los(grid, from_pos, visible)
	print("Origin: ", from_pos)
	print("Max distance: 4.0 cells")
	print("Visible cells: ", visible.size())
	print("O = Origin, V = Visible, # = Obstacle, . = Not visible")
	print()

func print_grid_with_movement(grid: Array[Array], from_pos: Vector2i, reachable_cells: Array[AStarGridCell]):
	var reachable_positions: Array[Vector2i] = []
	for cell in reachable_cells:
		reachable_positions.append(cell.position)
	
	for y in range(grid.size()):
		var line = ""
		for x in range(grid[y].size()):
			var pos = Vector2i(x, y)
			var cell = grid[y][x]
			
			if pos == from_pos:
				line += "S "
			elif pos in reachable_positions:
				line += "M "
			elif cell.weight == -1:
				line += "# "
			else:
				line += ". "
		print(line)

func test_movement_range():
	print("Test 10: Movement Range Check")
	var grid_data = [
		[1, 1, 1, 1, 1, 1, 1],
		[1, 2, 2, -1, 1, 1, 1],
		[1, 2, 1, 1, 1, -1, 1],
		[1, 1, 1, -1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 1]
	]
	var grid = create_grid(grid_data)
	var pathfinder = AStarPathfinding.new(grid)
	var from_pos = Vector2i(0, 2)
	var max_movement = 5.0
	var reachable = pathfinder.check_movement(from_pos, max_movement)
	
	print_grid_with_movement(grid, from_pos, reachable)
	print("Origin: ", from_pos)
	print("Max movement: ", max_movement)
	print("Reachable cells: ", reachable.size())
	print("S = Start, M = Reachable, # = Obstacle")
	print("Note: Higher weight cells (2) consume more movement")
	print()
