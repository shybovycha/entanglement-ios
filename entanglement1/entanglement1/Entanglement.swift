//
//  Entanglement.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 05/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Darwin

class Tile {
    var connections: [(Int, Int)] = []

    func output(input: Int) -> Int {
        for (inPin, outPin) in self.connections {
            if inPin == input {
                return outPin
            }

            if outPin == input {
                return inPin
            }
        }

        print("Could not find output for \(input) in \(connections)")

        return -1
    }

    func outputFromNeighbourOutput(output: Int) -> Int {
        return self.output(self.input(output))
    }

    func input(output: Int) -> Int {
        if (output % 2) == 0 {
            return (output + 12 - 5) % 12
        } else {
            return (output + 12 + 5) % 12
        }
    }

    func rotate(direction: Int) {
        var res: [(Int, Int)] = []

        for (input, output) in self.connections {
            res.append(((input + (direction * 2)) % 12, (output + (direction * 2)) % 12))
        }

        self.connections = res
    }

    // ↻
    func rotateRight() {
        self.rotate(1)
    }

    // ↺
    func rotateLeft() {
        self.rotate(-1)
    }

    // draw connections
    func render() {
        print("*", terminator: "")
    }

    func toString() -> String {
        return "\(self.connections)"
    }
}

class ZeroTile : Tile {
    override init() {
        super.init()

        self.connections = [(0, 0)]
    }

    override func render() {
        print("0", terminator: "")
    }
}

class BorderTile : Tile {
    // draw wall
    override func render() {
        print("x", terminator: "")
    }
}

class EmptyTile : Tile {
    // draw an empty space
    override func render() {
        print("o", terminator: "")
    }
}

class PlaceholderTile : Tile {

}

class NonEmptyTile : Tile {

}

class PathItem {
    var u: Int, v: Int
    var input: Int
    var output: Int

    init(u: Int, v: Int, input: Int, output: Int) {
        self.u = u
        self.v = v
        self.input = input
        self.output = output
    }
}

class Path {
    var items: [PathItem] = []

    init(centerU u: Int = 4, centerV v: Int = 4) {
        self.expand(u, v: v, input: 0, output: 0)
    }

    func expand(u: Int, v: Int, input: Int, output: Int) {
        self.items.append(PathItem(u: u, v: v, input: input, output: output))
    }

    func toString() -> String {
        var res = "x"

        for item in self.items {
            res += " -> [\(item.u), \(item.v)] \(item.input) -> \(item.output)"
        }

        return res
    }

    func lastOutput() -> Int {
        return self.items.last!.output
    }
}

class Field {
    var tiles: [[Tile]] = []
    var path: Path = Path()
    var nextPlace: (Int, Int) = (5, 5)
    var pathFinished: Bool = false

    init() {
        self.tiles = []

        for i in 0...8 {
            self.tiles.append([])

            for _ in 0...8 {
                self.tiles[i].append(PlaceholderTile())
            }
        }

        self.tiles[4][4] = ZeroTile()

        for i in 5...8 {
            for t in 0...(8 - i) {
                self.tiles[t][i + t] = EmptyTile()
                self.tiles[i + t][t] = EmptyTile()
            }
        }

        for i in 0...4 {
            self.tiles[0][i] = BorderTile()
            self.tiles[i][0] = BorderTile()
            self.tiles[8][i + 4] = BorderTile()
            self.tiles[i + 4][8] = BorderTile()
        }

        for i in 1...4 {
            self.tiles[i][i + 4] = BorderTile()
            self.tiles[i + 4][i] = BorderTile()
        }
    }

    func findNextPlace(path: Path, nextPlace: (Int, Int)) -> (Int, Int) {
        var u: Int, v: Int
        (u, v) = nextPlace

        let output: Int = path.lastOutput()

        switch output {
        case 0, 1:
            return (u + 1, v + 1)
        case 2, 3:
            return (u + 1, v)
        case 4, 5:
            return (u, v - 1)
        case 6, 7:
            return (u - 1, v - 1)
        case 8, 9:
            return (u - 1, v)
        case 10, 11:
            return (u, v + 1)
        default:
            return (u, v)
        }
    }

    func isPathFinished() -> Bool {
        return self.pathFinished
    }

    func findFuturePath(tile: NonEmptyTile) -> (Path, (Int, Int)) {
        let tmpPath: Path = Path()
        var tmpNextPlace: (Int, Int) = self.nextPlace
        var u: Int, v: Int

        tmpPath.items = [self.path.items.last!]

        (u, v) = tmpNextPlace

        while true {
            let lastOutput: Int = tmpPath.lastOutput()
            var nextTile: Tile

            if u == self.nextPlace.0 && v == self.nextPlace.1 {
                nextTile = tile
            } else {
                nextTile = self.tiles[u][v]
            }

            if !(nextTile is NonEmptyTile) {
                break
            }

            tmpPath.expand(u, v: v, input: nextTile.input(lastOutput), output: nextTile.outputFromNeighbourOutput(lastOutput))

            tmpNextPlace = self.findNextPlace(tmpPath, nextPlace: tmpNextPlace)

            if u == tmpNextPlace.0 && v == tmpNextPlace.1 {
                break
            }

            (u, v) = tmpNextPlace
        }

        tmpPath.items.removeFirst()

        return (tmpPath, tmpNextPlace)
    }

    func placeTile(tile: NonEmptyTile) {
        var u: Int, v: Int

        (u, v) = self.nextPlace
        self.tiles[u][v] = tile

        while self.tiles[u][v] is NonEmptyTile {
            let lastOutput: Int = self.path.lastOutput()

            self.path.expand(u, v: v, input: self.tiles[u][v].input(lastOutput), output: self.tiles[u][v].outputFromNeighbourOutput(lastOutput))

            self.nextPlace = self.findNextPlace(self.path, nextPlace: self.nextPlace)

            if u == self.nextPlace.0 && v == self.nextPlace.1 {
                break
            }

            (u, v) = self.nextPlace
        }

        // (self.path, self.nextPlace) = self.findPossiblePath()

        (u, v) = self.nextPlace

        if self.tiles[u][v] is ZeroTile || self.tiles[u][v] is BorderTile {
            self.pathFinished = true
        }
    }

    func render() {
        for row in self.tiles {
            for tile in row {
                tile.render()
            }

            print("")
        }
    }
}

public enum GameError : ErrorType {
    case GameOver
}

public class Game {
    var field: Field = Field()
    var pocket: NonEmptyTile = NonEmptyTile()
    var nextTile: NonEmptyTile = NonEmptyTile()
    var state: String {
        return "Is over: \(self.isGameOver())\nNext tile: \(self.nextTile.toString())\nPocket: \(self.pocket.toString())\nPath: \(self.field.path.toString())"
    }

    init() {
        self.nextTile = self.generateTile()
        self.pocket = self.generateTile()
    }

    func isGameOver() -> Bool {
        return self.field.isPathFinished()
    }

    func usePocket() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        swap(&self.pocket, &self.nextTile)
    }

    func rotateTileRight() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        self.nextTile.rotateRight()
    }

    func rotateTileLeft() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        self.nextTile.rotateLeft()
    }

    func placeTile() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        self.field.placeTile(self.nextTile)
        self.nextTile = self.generateTile()
    }

    func generateTile() -> NonEmptyTile {
        let tile = NonEmptyTile()

        var pool = [Int](0...11)

        for _ in 0...5 {
            var i = Int(arc4random_uniform(UInt32(pool.count)))
            let a = pool[i]
            pool.removeAtIndex(i)
            i = Int(arc4random_uniform(UInt32(pool.count)))
            let b = pool[i]
            pool.removeAtIndex(i)

            tile.connections.append((a, b))
        }

        return tile
    }
}
