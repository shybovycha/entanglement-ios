//
//  PathItem.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

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
