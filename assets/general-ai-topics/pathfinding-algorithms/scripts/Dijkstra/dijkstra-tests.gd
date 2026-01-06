## DijkstraTests.gd - Test suite
class_name DijkstraTests
extends Node

func _ready() -> void:
	print("=== DIJKSTRA PATHFINDING TESTS ===\n")
	
	test_simple_path()
	test_weighted_path()
	test_diagonal_movement()
	test_obstacles()
	test_no_path()
	test_complex_maze()
	
	print("\n=== ALL TESTS COMPLETED ===")

func test_simple_path() -> void:
	print("--- Test 1: Simple Path (3x3 grid, uniform weight) ---")
	var grid = DijkstraGrid.new(3, 3)
	
	# Create uniform grid
	for x in range(3):
		for y in range(3):
			grid.set_cell(Vector2i(x, y), 1.0)
	
	var pathfinder = DijkstraPathfinder.new(grid, false)
	var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(2, 2))
	
	print("Start: (0, 0), Goal: (2, 2)")
	print("Allow diagonal: false")
	print(path)
	assert(path.is_valid(), "Path should be valid")
	assert(path.total_weight == 4.0, "Total weight should be 4.0")
	print()

func test_weighted_path() -> void:
	print("--- Test 2: Weighted Path (Different terrain costs) ---")
	var grid = DijkstraGrid.new(5, 5)
	
	# Create grid with varying weights
	for x in range(5):
		for y in range(5):
			if x == 2 and y > 0 and y < 4:
				grid.set_cell(Vector2i(x, y), 10.0) # Expensive column
			else:
				grid.set_cell(Vector2i(x, y), 1.0)
	
	var pathfinder = DijkstraPathfinder.new(grid, false)
	var path = pathfinder.find_path(Vector2i(0, 2), Vector2i(4, 2))
	
	print("Start: (0, 2), Goal: (4, 2)")
	print("Column x=2 has weight 10.0, others have weight 1.0")
	print(path)
	assert(path.is_valid(), "Path should be valid")
	print()

func test_diagonal_movement() -> void:
	print("--- Test 3: Diagonal Movement Comparison ---")
	var grid = DijkstraGrid.new(4, 4)
	
	for x in range(4):
		for y in range(4):
			grid.set_cell(Vector2i(x, y), 1.0)
	
	print("A) Without diagonal movement:")
	var pathfinder_no_diag = DijkstraPathfinder.new(grid, false)
	var path_no_diag = pathfinder_no_diag.find_path(Vector2i(0, 0), Vector2i(3, 3))
	print(path_no_diag)
	
	print("B) With diagonal movement:")
	var pathfinder_diag = DijkstraPathfinder.new(grid, true)
	var path_diag = pathfinder_diag.find_path(Vector2i(0, 0), Vector2i(3, 3))
	print(path_diag)
	
	assert(path_diag.cells.size() < path_no_diag.cells.size(), 
		   "Diagonal path should have fewer cells")
	print()

func test_obstacles() -> void:
	print("--- Test 4: Pathfinding Around Obstacles ---")
	var grid = DijkstraGrid.new(5, 5)
	
	# Create grid with wall
	for x in range(5):
		for y in range(5):
			if x == 2 and y > 0 and y < 4:
				grid.set_cell(Vector2i(x, y), -1.0) # Wall
			else:
				grid.set_cell(Vector2i(x, y), 1.0)
	
	var pathfinder = DijkstraPathfinder.new(grid, false)
	var path = pathfinder.find_path(Vector2i(0, 2), Vector2i(4, 2))
	
	print("Start: (0, 2), Goal: (4, 2)")
	print("Wall at x=2, y=1-3 (weight=-1)")
	print(path)
	assert(path.is_valid(), "Path should find way around wall")
	print()

func test_no_path() -> void:
	print("--- Test 5: No Path Available ---")
	var grid = DijkstraGrid.new(5, 3)
	
	# Create grid with complete wall
	for x in range(5):
		for y in range(3):
			if x == 2:
				grid.set_cell(Vector2i(x, y), -1.0) # Complete vertical wall
			else:
				grid.set_cell(Vector2i(x, y), 1.0)
	
	var pathfinder = DijkstraPathfinder.new(grid, false)
	var path = pathfinder.find_path(Vector2i(0, 1), Vector2i(4, 1))
	
	print("Start: (0, 1), Goal: (4, 1)")
	print("Complete wall at x=2")
	print("Path found: ", path.is_valid())
	assert(not path.is_valid(), "Should not find path through complete wall")
	print()

func test_complex_maze() -> void:
	print("--- Test 6: Complex Maze with Mixed Weights ---")
	var grid = DijkstraGrid.new(6, 6)
	
	# Create interesting terrain
	var terrain = [
		[1, 1, 1, 5, 1, 1],
		[1, -1, 1, 5, -1, 1],
		[1, -1, 1, 1, 1, 1],
		[1, 2, 2, -1, 1, 1],
		[1, 2, 2, -1, 1, 1],
		[1, 1, 1, 1, 1, 1]
	]
	
	for x in range(6):
		for y in range(6):
			grid.set_cell(Vector2i(x, y), terrain[y][x])
	
	var pathfinder = DijkstraPathfinder.new(grid, true)
	var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(5, 5))
	
	print("Start: (0, 0), Goal: (5, 5)")
	print("Terrain: 1=normal, 2=grass, 5=swamp, -1=wall")
	print("Allow diagonal: true")
	print(path)
	assert(path.is_valid(), "Should find path through complex terrain")
	print()
	
