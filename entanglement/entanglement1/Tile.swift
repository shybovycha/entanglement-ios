//
//  Tile.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

class Tile {
    var connections: [(Int, Int)] = []
    
    func output(from input: Int) throws -> Int {
        for (inPin, outPin) in self.connections {
            if inPin == input {
                return outPin
            }
            
            if outPin == input {
                return inPin
            }
        }
        
        throw GameError.invalidTile
    }
    
    func outputFromNeighbourOutput(from output: Int) throws -> Int {
        return try self.output(from: self.input(to: output))
    }
    
    func input(to output: Int) -> Int {
        if (output % 2) == 0 {
            return (output + 12 - 5) % 12
        } else {
            return (output + 12 + 5) % 12
        }
    }
    
    func rotate(_ direction: Int) {
        var res: [(Int, Int)] = []
        
        for (input, output) in self.connections {
            res.append(((input + (direction * 2) + 12) % 12, (output + (direction * 2) + 12) % 12))
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
