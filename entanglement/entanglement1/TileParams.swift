//
//  TileParams.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

open class TileParams {
    var connections: [(Int, Int)]
    var highlight: [(Int, Int)]
    var mark: [(Int, Int)]
    var position: (Int, Int)

    init(connections: [(Int, Int)], highlight: [(Int, Int)] = [], mark: [(Int, Int)] = [], position: (Int, Int) = (-1, -1)) {
        self.connections = connections
        self.highlight = highlight
        self.position = position
        self.mark = mark
    }
}
