# Grid Maze Generator

Complete console application for Godot 4.5 that generates mazes with a minimum path length constraint. Here's what it does:

## Features:

1.  **Maze Generation**: Uses recursive backtracking (DFS) to create a perfect maze where every cell is reachable
2.  **Minimum Distance Constraint**: Regenerates mazes until the shortest path between Start and End is at least 20 cells long
3.  **Visual Display**: Shows the maze in ASCII art with:
    -   `S` for Start (top-left corner)
    -   `E` for End (bottom-right corner)
    -   `*` for the shortest path cells
    -   Walls shown with `+`, `-`, and `|` characters
4.  **Path Verification**:
    -   Uses BFS to find the shortest path
    -   Verifies every cell in the path is properly connected
    -   Displays the complete path coordinates
5.  **Console Output**: Shows generation attempts, path statistics, and full traversal verification

## New Features:

1.  **Dead End Probability**: Added `DEAD_END_PROBABILITY = 0.3` (30% chance) that controls how often the algorithm creates dead ends
2.  **Random Dead End Creation**: During maze generation, after connecting to a new room, there's a random chance to stop exploring that branch, creating a dead end
3.  **Dead End Analysis**: New function that:
	-   Counts all dead ends in the maze
	-   Lists their coordinates
	-   Shows which are the Start or End points
	-   Calculates the dead end ratio

## How It Works:

When the algorithm adds a new room, it rolls a random number. If it's below the `DEAD_END_PROBABILITY`, it immediately backtracks instead of continuing, leaving that room as a dead end (only one passage).

## Customization:

You can adjust the dead end frequency:

-   `DEAD_END_PROBABILITY = 0.0` → No dead ends (like before)
-   `DEAD_END_PROBABILITY = 0.3` → 30% chance (good balance)
-   `DEAD_END_PROBABILITY = 0.5` → 50% chance (lots of dead ends)
-   `DEAD_END_PROBABILITY = 0.7` → 70% chance (very branchy maze)

The maze now has more variety and challenge with dead ends that players can explore but won't lead to the goal!
