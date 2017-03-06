//
//  Game.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

open class Game {
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

    func usePocket() {
        swap(&self.pocket, &self.nextTile)
    }

    func rotateTileRight() {
        self.nextTile.rotateRight()
    }

    func rotateTileLeft() {
        self.nextTile.rotateLeft()
    }

    func placeTile() throws {
        if isGameOver() {
            throw GameError.gameOver
        }

        try self.field.placeTile(self.nextTile)
        self.nextTile = self.generateTile()
    }

    func generateTile() -> NonEmptyTile {
        let tile = NonEmptyTile()

        var pool = [Int](0...11)

        for _ in 0...5 {
            var i = Int(arc4random_uniform(UInt32(pool.count)))
            let a = pool[i]
            pool.remove(at: i)
            i = Int(arc4random_uniform(UInt32(pool.count)))
            let b = pool[i]
            pool.remove(at: i)

            tile.connections.append((a, b))
        }

        return tile
    }

    func pointsGathered() throws -> Int {
        var points: Int = 0

        let (futurePath, (_, _)) = try self.field.findFuturePath(self.nextTile)

        for i in 0...futurePath.items.count - 1 {
            points += i + 1
        }
        
        return points
    }
}
