//
//  RenderingParams.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import UIKit

open class RenderingParams {
    var sideLength: Int
    var stroke: Int = 1
    var pathStroke: Int = 4
    var strokeColor: UIColor
    var pathColor: UIColor
    var highlightPathColor: UIColor
    var markPathColor: UIColor

    init(sideLength: Int,
        stroke: Int = 1,
        pathStroke: Int = 4,
        strokeColor: UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
        pathColor: UIColor = UIColor.white,
        highlightPathColor: UIColor = UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 1.0),
        markPathColor: UIColor = UIColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1.0)) {
            self.sideLength = sideLength
            self.stroke = stroke
            self.pathStroke = pathStroke
            self.strokeColor = strokeColor
            self.pathColor = pathColor
            self.highlightPathColor = highlightPathColor
            self.markPathColor = markPathColor
    }
}
