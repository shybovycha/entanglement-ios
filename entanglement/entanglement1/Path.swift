//
//  Path.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

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
