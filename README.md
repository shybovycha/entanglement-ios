# Entanglement for iOS

## Overview

This is a clone of [Entanglement](http://entanglement.gopherwoodstudios.com/)
puzzle game for iOS, made with Swift. You start with a tile at the center of
the board, which gives you the tiny amount of a red
line. Your goal is to create the longest red line path possible.
You can use either the tile in your hands or swap it with the one
in your pocket.

![Screenshot](https://raw.githubusercontent.com/shybovycha/entanglement-ios/master/screen1.png)

## Architecture

The board is represented as a two-dimensional array of `Tile` objects.
Both map and each tile are hexagons.

### Tiles

Each `Tile` object has 12 possible path fragments.
Each side of a tile holds two ends of a path fragment.
Connections between tile sides are represented by 12-element array,
`connections`, where each element is a tuple, containing the beginning
and the end points' indices for each path fragment.
Order for those numbers does not matter inside `connections` array.
But it does matter in the meaning of the whole tile:

```
      --c0------c1---      
     /               \     
  c11                 c2   
   /                   \   
  /                     \  
c10                     c3 
/                         \
\                         /
c9                      c4 
  \                     /  
   \                   /   
    c8               c5    
     \               /     
      --c7------c6---     
```

Here, if you join, say, `c0` and `c5`, you shall got the line fragment.

`Tile` class has these helper methods:

* `outputFromNeighbourOutput(output: Int)` - for finding out the connection "pin" index
  for the neighbor tiles *(if you place two tiles one above another,
  their pins' indices on the join line will be different - the top
  one will have pins `c7` and `c6` whilst the bottom one will have
  `c0` and `c1`)*.

* `intput(output: Int)` - for fianding the endpoint for a pin *(`c5` if `c0` is given or `c0` if `c5` is given, in our example)*

* `output(intput: Int)` - finds the correspondence between neighbour pins *(in our example with stacked tiles, this method associates `c0` with `c7` or `c6` with `c1` and others)*

* `rotate(direction: Int)` / `rotateLeft()` / `rotateRight()` - rotates a tile, changing pins on its sides

There are a few derived classes. Those are used to distinguish the borders of
a board (`BorderTile`), empty places within a board (`Tile`),
tiles outside the board (`EmptyTile`), the starting point (`ZeroTile`)
and the tiles which already on the map (`NonEmptyTile`).

### Board

Board stores tiles, which have been already placed and those which are empty,
and the "zero" one *(the one where you start)*, and the borders... It's all
about the board.

The tiles are stored in a two-dimensional array, but here's the trick:
to draw them *(and for the better understanding's sake)* I placed them
in the non-orthogonal coordinate system *(note the `u` and `v` coordinates
used in the code)*, formed by a two lines, lying through the tiles' centers
and crossing under 120<sup>o</sup> angle:

```
(0,8)  (1,8)  (2,8)  (3,8)  (4,8)  (5,8)  (6,8)  (7,8)  (8,8)
       (0,7)  (1,7)  (2,7)  (3,7)  (4,7)  (5,7)  (6,7)  (7,7)  (8,7)
              (0,6)  (1,6)  (2,6)  (3,6)  (4,6)  (5,6)  (6,6)  (7,6)  (8,6)
                     (0,5)  (1,5)  (2,5)  (3,5)  (4,5)  (5,5)  (6,5)  (7,5)  (8,5)
                            (0,4)  (1,4)  (2,4)  (3,4)  (4,4)  (5,4)  (6,4)  (7,4)  (8,4)
                                   (0,3)  (1,3)  (2,3)  (3,3)  (4,3)  (5,3)  (6,3)  (7,3)  (8,3)
                                          (0,2)  (1,2)  (2,2)  (3,2)  (4,2)  (5,2)  (6,2)  (7,2)  (8,2)
                                                 (0,1)  (1,1)  (2,1)  (3,1)  (4,1)  (5,1)  (6,1)  (7,1)  (8,1)
                                                        (0,0)  (1,0)  (2,0)  (3,0)  (4,0)  (5,0)  (6,0)  (7,0)  (8,0)
```

The center of the map, the form of the map - those two are configured
parameters of the board, but generally those are set to a **hexagon** board
shape and its center in the **(4, 4)** point.

Board class provides a way to detect the place for the tile, which will be placed next.
This is done using simple `switch ... case` operator. Say, you have your last tile placed at
`(u, v)` point and the line ends at its `c_i` pin. The `findNextPlace() -> (Int, Int)` method
will provide you with a neighbour tile placeholder' coordinates. Note: this method does **not**
check if the placeholder contains `BorderTile` or `ZeroTile` or whatever - this check is performed
whilst the new tile is being placed.

The `placeTile(tile: NonEmptyTile)` method performs placing tile and checks for the game end.
This method also performs the extension of a path. The information about current path is
stored in the `Path` class instance in the form of `(u, v, localInput, localOutput)` structure.
Most of those parameters are stored for the debugging purposes - the only thing you need is
the output pin of each tile.

### Game

`Game` class encapsulates `Board` object, next tile *(the one you "hold in your hand")* and the "pocket"
tile. It also provides convenient methods to manipulate game state - `rotateTileLeft()`,
`rotateTileRight()`, `usePocket()`, `placeTile()` and `isGameOver() -> Bool` to check if the game
goes on.

You can use those method and create any UI you can imagine *(to display game state)* to create
your own distribution of the game.
