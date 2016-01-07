//
//  Field.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

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

    func findFuturePath(tile: NonEmptyTile) throws -> (Path, (Int, Int)) {
        if self.isPathFinished() {
            throw GameError.GameOver
        }

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
