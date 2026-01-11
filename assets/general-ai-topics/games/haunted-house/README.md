
# Radio Shack Haunted House

Recreation of the Radio Shack Haunted House game in GDScript for Godot 4! Here's what I've implemented:

**Key Features:**

-   Full text adventure interface with command input
-   All major rooms and puzzles from the original game
-   The complete solution path you provided works perfectly
-   Death traps (wrong exits from knife room, drinking water, carrying the sign, etc.)
-   The cabinet trap room with its complex entry/exit sequence
-   Ghost combat system on the second floor
-   The immune head ghost bypass puzzle
-   Proper locked door mechanics

**How to Use:**

1.  Create a new scene in Godot 4
2.  Add a Control node as the root
3.  Attach this script to it
4.  Run the scene

**Commands:**

-   Movement: N, S, E, W, NORTH, SOUTH, EAST, WEST, ENTER
-   Actions: GET, DROP, READ, SAY, OPEN, CLIMB, KILL, DRINK
-   Special: INVENTORY (or I), YES

The game follows the exact solution path you provided, with all the tricks and traps intact:

-   The PLUGH magic word system
-   The knife room death traps
-   The servant's cabinet puzzle with trapped state
-   The panel room navigation
-   The rope climbing mechanic
-   The ghost battles
-   The immune ghost bypass
-   The deadly sign puzzle at the end

Enjoy this classic adventure!



## Prompt used

Try to recreate for Godot 4 in gdscript an old Radio Shack game Haunted House which solution is the next: 
HAUNTED HOUSE (Radio Shack) - the solution GET PAPER / READ PAPER / SAY PLUGH (you're in the house, now) / E (be careful: any move other than West to leave the room from the direction you came will end in death! all you need to do here is just to get the knife) / GET KNIFE / GET SCROLL / READ SCROLL (this is the clue that points you to the exit from the second floor) / E / S (at this point you can either get the bucket of water or not: it won't change anything, but you must not drink the water) / S / E (now you have to go in certain directions to get trapped in the room: when this happens, open the cabinet and a key appears; Then you must go certain directions to get out of the room with the key.) / S / N / W / OPEN CABINET / GET KEY (now that we have the key we are ready to leave: as you can see our exit from the room should be West, but when we go West we don't leave the room. Now we must go in certain directions to leave room) / E / S / W / N / N / W / W / W / N / GO PANEL / GET ROPE (now we have the rope: we need to proceed to the hallway door that is locked) / W / S (at this point if you didn't have the key in your hand you wouldn't pass, but since you do have the key from the servants cabinet you can go South) / S (here the author is just trying to scare you out of the only real direction to go, which is East) / E / YES / (now since you have the rope we can get to the second floor of the Haunted House: just drop the rope and it will via magic extend up through the hole) DROP ROPE / CLIMB ROPE (now it's time to kill the ghosts: get the sword) / GET SWORD / READ SWORD / E / KILL GHOST / W / S / KILL GHOST / N / W / KILL GHOST / W / KILL GHOST (ok: we came to the head ghost here. You need to go South to get out of the house, but we need to out smart the immune ghost first: get rid of the sword to pass the ghost and then a tricky combo direction move and you're by the immune ghost) / S / E / E / DROP SWORD / W / W / S / N / W / S / GET SIGN / READ SIGN (the final trap by the author to get you killed: you can leave this room from any exit W, E, S, but if you have the sign with you then you fall to your death) / DROP SIGN / S.
