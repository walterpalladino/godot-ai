Based on Claude code and fexed / modified


# Dijkstra Vs AStar

A* search is an extension of Dijkstra's algorithm that uses a  **heuristic function to guide its search toward the goal**, making it much faster in most practical scenarios.  Dijkstra's, by contrast, explores all possible paths in an expanding circle from the start point to find the shortest path to  _all_  other nodes, which is more thorough but less efficient for a single destination.

## Key Differences


| sas | sas | sasa |
|--|--|--|
|  |  |  |


| Feature | Dijkstra's Algorithm | AStar Algorithm | 
|--|--|--|
| **Search Strategy** | Uninformed search; explores outward in a breadth-first manner based purely on accumulated path cost (g(n)). |Informed search; uses a heuristic (h(n)) to estimate the distance to the goal, guiding the search. |
| **Optimality** | Guaranteed to find the absolute shortest path, provided edge weights are non-negative. | Guaranteed to find the shortest path only if the heuristic function is "admissible" (never overestimates the true cost). |
| **Performance** | Slower; can explore a large number of irrelevant nodes because it doesn't know where the goal is. | Faster in most cases; the heuristic significantly reduces the number of nodes explored, focusing the search on promising areas. |
| **Goal** | Finds the shortest path from the source to  _all_  other nodes in the graph. | Finds the shortest path from the source to a  _single specific_  goal node. |
| **Implementation** | Simpler, as it does not require a heuristic function. | More complex, as developing an effective and admissible heuristic can be challenging. |


### Summary Comparison

-   __A_  is essentially Dijkstra's with an optimization_*. You can turn A* into Dijkstra's by setting its heuristic function  `h(n)`  to zero for all nodes.
-   If your primary concern is speed and you have a good way to estimate the distance to the goal (e.g., straight-line distance on a map), A* is the better choice.
-   If you need to find the shortest path to every location in the graph or cannot devise a reliable heuristic, Dijkstra's is the robust, guaranteed optimal solution.



This is a **Dijkstra's pathfinding algorithm implementation** in GDScript (for Godot Engine) that finds the shortest path on a weighted grid.

## Core Components

**GridCell Class**: Stores data for each grid position including coordinates, traversal weight (cost to move through), and whether it's passable.

**Grid Structure**: A 2D array representing the game map, with configurable dimensions that can be initialized from custom data.

**Pathfinding Algorithm**: Implements Dijkstra's algorithm, which finds the optimal path considering terrain weights. It:

-   Tracks distances to all cells from the start point
-   Uses a priority queue approach to visit cells in order of shortest distance
-   Records the previous cell for each position to reconstruct the final path
-   Handles obstacles by skipping non-traversable cells

**Navigation System**: Provides 4-directional movement (up, down, left, right) and validates positions are within grid bounds.

## Example Usage

The code includes a demonstration that creates a 5×5 grid with:

-   Standard terrain (weight 1.0) - easy to traverse
-   Difficult terrain (weight 5.0) - expensive to cross
-   Medium terrain (weight 2.0) - moderate cost
-   Obstacles (non-traversable) - impassable barriers

It finds a path from top-left to bottom-right and visualizes the result in the console, showing:

-   `S` = Start position
-   `G` = Goal position
-   `#` = Obstacles
-   `*` = Path tiles
-   `.` = Empty traversable tiles

The algorithm will route around obstacles and prefer lower-weight terrain to minimize total path cost.


**`allow_diagonal`**: Boolean flag to enable/disable 8-directional movement (default: false for 4-directional).

**`diagonal_cost_multiplier`**: Sets the cost of diagonal movement (default: 1.414 ≈ √2 for realistic Euclidean distance).

**Corner Cutting Prevention**: Diagonal movement is blocked if either adjacent cardinal cell is an obstacle, preventing unrealistic "squeezing through" corners.

**Dynamic Movement Cost**: The pathfinding algorithm now calculates different costs for cardinal vs diagonal moves.

## New Methods

-   `set_allow_diagonal(enabled: bool)` - Toggle diagonal movement
-   `set_diagonal_cost_multiplier(multiplier: float)` - Adjust diagonal cost
-   `_is_diagonal_passable()` - Validates diagonal moves aren't blocked by adjacent walls
-   `_get_movement_cost()` - Calculates appropriate cost based on movement direction

## Example Comparison

The example now runs pathfinding **twice** on the same grid:

1.  **Without diagonals** - Uses only 4 directions (up/down/left/right)
2.  **With diagonals** - Uses all 8 directions, typically finding shorter paths

This lets you see how diagonal movement creates more efficient routes while respecting terrain costs and obstacles.





## Key Particularities Documented in Code:

1.  **Hexagon Orientation: FLAT-TOP**
	-   Hexagons have flat edges on top/bottom and pointy sides left/right
	-   This is the "odd-r horizontal layout"
2.  **Offset System**
	-   **ODD-numbered ROWS** (1, 3, 5...) are shifted **RIGHT** by half a hex width
	-   Even rows (0, 2, 4...) are not offset
3.  **Neighbor Directions**
	-   The 6 neighbors are: **East, Southeast, Southwest, West, Northwest, Northeast**
	-   Direction offsets change based on whether you're on an odd or even row
	-   Odd rows: neighbors shifted right relative to even rows
4.  **Coordinate System**
	-   X = column (increases right)
	-   Y = row (increases down)
	-   Position stored as Vector2i(column, row)
5.  **Visualization**
	-   Odd rows are indented with a space to show the rightward offset visually in the console

This is the standard layout used in many hex-based games and matches well with Godot's TileMap when configured for flat-top hexagons!



# Pure Grid AStar implementation

## Key Features:

1.  **GridCell class** - Stores position and weight. Weight of -1 means non-traversable
2.  **PathResult class** - Contains the complete path with:
	-   Array of traversed cells
	-   Total accumulated weight
	-   Success status
3.  **AStarPathfinding class** - The main pathfinding algorithm with:
	-   Grid-based navigation
	-   Manhattan distance heuristic (4-directional movement)
	-   Weight-aware pathfinding (prefers lower-weight paths)
4.  **AStarTests class** - Comprehensive test suite with 6 different scenarios

## Test Cases:

1.  **Simple Path** - Basic straight-line pathfinding
2.  **Obstacles** - Navigation around blocked cells
3.  **Weighted Path** - Chooses optimal route based on cell weights
4.  **No Path** - Handles impossible paths gracefully
5.  **Narrow Gap** - Finds path through tight spaces
6.  **Complex Maze** - Navigates through complicated layouts

## Usage:

gdscript

```gdscript
# Create your grid
var grid_data = [
	[1, 1, 1],
	[1, -1, 1],
	[1, 1, 1]
]
var grid = create_grid(grid_data)

# Find path
var pathfinder = AStarPathfinding.new(grid)
var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(2, 2))

# Check results
if path.success:
	print("Total weight: ", path.total_weight)
	for cell in path.cells:
		print("Position: ", cell.position, " Weight: ", cell.weight)
```

The visualization shows S (start), E (end), * (path), # (obstacles), and . (traversable cells).


### 1. **Diagonal Movement Support**

-   Added `allow_diagonal` parameter to the `_init` method (default: `false`)
-   Modified `get_neighbors()` to include 8 diagonal directions when enabled
-   Enables more natural pathfinding for open areas

### 2. **Custom Heuristic Function**

-   Added `custom_heuristic` parameter to `_init` (optional `Callable`)
-   If not provided, uses the default Manhattan distance heuristic
-   Allows flexibility for different pathfinding strategies

## Usage Examples:

gdscript

```gdscript
# Standard 4-directional movement with Manhattan heuristic
var pathfinder1 = AStarPathfinding.new(grid)

# Enable 8-directional diagonal movement
var pathfinder2 = AStarPathfinding.new(grid, true)

# Custom heuristic (Euclidean distance)
func euclidean(a: Vector2i, b: Vector2i) -> float:
	return sqrt((a.x - b.x)**2 + (a.y - b.y)**2)

var pathfinder3 = AStarPathfinding.new(grid, true, euclidean)
```

## New Test Cases:

-   **Test 7**: Demonstrates diagonal movement through a maze (much shorter path)
-   **Test 8**: Shows custom Euclidean heuristic creating a more direct diagonal path

The diagonal movement is particularly useful for games and simulations where characters can move in all 8 directions!


# Pure Dijkstra pathfinding system for Grids

## Components:

1.  **DijkstraCell** - Represents a grid cell with position, weight, and traversability
2.  **DijkstraPath** - Contains the resulting path with cells and total weight calculation
3.  **DijkstraGrid** - Manages the grid structure and cell storage
4.  **DijkstraPathfinder** - The main pathfinding algorithm with optional diagonal movement
5.  **DijkstraTests** - Comprehensive test suite

## Key Features:

-   ✅ Grid-based navigation
-   ✅ Weight-based pathfinding (negative weights = impassable)
-   ✅ Optional diagonal movement
-   ✅ Complete path information with individual cell weights
-   ✅ Total path weight calculation
-   ✅ All classes prefixed with "Dijkstra"

## Test Examples Included:

1.  **Simple Path** - Basic pathfinding on uniform grid
2.  **Weighted Path** - Different terrain costs affecting route choice
3.  **Diagonal Movement** - Comparison with/without diagonal movement
4.  **Obstacles** - Pathfinding around walls
5.  **No Path** - Handling impossible routes
6.  **Complex Maze** - Mixed terrain types with diagonal movement

## Usage Example:

gdscript

```gdscript
var grid = DijkstraGrid.new(10, 10)
# Set up cells
grid.set_cell(Vector2i(0, 0), 1.0)  # Traversable
grid.set_cell(Vector2i(5, 5), -1.0) # Wall

var pathfinder = DijkstraPathfinder.new(grid, true) # true = allow diagonal
var path = pathfinder.find_path(Vector2i(0, 0), Vector2i(9, 9))

print("Total weight: ", path.total_weight)
for cell in path.cells:
	print(cell.position, " - weight: ", cell.weight)
```

To test, attach DijkstraTests to a node and run the scene!
