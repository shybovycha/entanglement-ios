//
//  EmptyTile.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

class EmptyTile : Tile {
    // draw an empty space
    override func render() {
        print("o", terminator: "")
    }
}
