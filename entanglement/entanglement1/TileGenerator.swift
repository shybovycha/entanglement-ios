//
//  TileGenerator1.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import UIKit

class TileGenerator {
    var sideLength: Int
    var stroke: Int
    var pathStroke: Int
    var strokeColor: UIColor
    var pathColor: UIColor
    var highlightPathColor: UIColor
    var markPathColor: UIColor

    var width: Int
    var height: Int
    var scaleCoefficient: Float
    var centerX: Int
    var centerY: Int

    let vertices: [(Int, Int)] = [(50, 0), (150, 0), (200, 87), (150, 173), (50, 173), (0, 87)]
    let pins: [(Int, Int)] = [(83, 0), (116, 0), (166, 29), (182, 58), (182, 116), (166, 145), (116, 173), (83, 173), (34, 145), (18, 116), (18, 58), (34, 29)]

    init(renderingParams: RenderingParams) {
        self.sideLength = renderingParams.sideLength
        self.stroke = renderingParams.stroke
        self.pathStroke = renderingParams.pathStroke
        self.strokeColor = renderingParams.strokeColor
        self.pathColor = renderingParams.pathColor
        self.highlightPathColor = renderingParams.highlightPathColor
        self.markPathColor = renderingParams.markPathColor

        self.scaleCoefficient = Float(self.sideLength) / 100.0

        self.width = Int(ceil(2.0 * Float(self.sideLength + (self.stroke * 2))))
        self.height = Int(ceil(1.73 * Float(self.sideLength + (self.stroke * 2))))

        self.centerX = (self.width / 2) + (self.stroke * 0)
        self.centerY = (self.height / 2) + (self.stroke * 0)
    }

    func uv2xy(uv: (Int, Int)) -> (Int, Int) {
        let u = uv.0, v = uv.1
        let kx = Float(u - v) * (3.0 / 2.0)
        let ky = Float(u + v) * (sqrt(3.0) / 2.0)
        let x = Int(ceil(kx * Float(self.sideLength + (self.stroke * 0))))
        let y = Int(ceil(ky * Float(self.sideLength + (self.stroke * 0))))

        let cx = 9 * (self.sideLength + (self.stroke * 0))
        let cy = Int(ceil(8.0 * sqrt(3.0) * Float(self.sideLength + (self.stroke * 0))))

        return (cx + x, cy - y)
    }

    func emptyTile(tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let _ = UIGraphicsGetCurrentContext()

        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func nonEmptyTile(tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        // draw outer shape
        let shapePathRef: CGMutablePathRef = CGPathCreateMutable()

        CGContextSetFillColorWithColor(context, UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).CGColor)
        CGContextSetLineJoin(context, CGLineJoin.Round)

        for i in 1...(self.vertices.count - 1) {
            let x1 = CGFloat(Float(self.vertices[i].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let y1 = CGFloat(Float(self.vertices[i].1) * self.scaleCoefficient + Float(self.stroke * 2))

            if i == 1 {
                let x0 = CGFloat(Float(self.vertices[i - 1].0) * self.scaleCoefficient + Float(self.stroke * 2))
                let y0 = CGFloat(Float(self.vertices[i - 1].1) * self.scaleCoefficient + Float(self.stroke * 2))
                CGPathMoveToPoint(shapePathRef, nil, x0, y0)
            }

            CGPathAddLineToPoint(shapePathRef, nil, x1, y1)
        }

        CGPathCloseSubpath(shapePathRef)

        CGContextAddPath(context, shapePathRef)
        CGContextFillPath(context)

        // draw connections
        for (c0, c1) in tileParams.connections {
            CGContextSetLineWidth(context, CGFloat(self.pathStroke))

            let connectionPathRef: CGMutablePathRef = CGPathCreateMutable()
            var pathColor: CGColor

            if tileParams.mark.contains({ ($0.0 == c0 && $0.1 == c1) || ($0.0 == c1 && $0.1 == c0) }) {
                pathColor = self.markPathColor.CGColor
            } else if tileParams.highlight.contains({ ($0.0 == c0 && $0.1 == c1) || ($0.0 == c1 && $0.1 == c0) }) {
                pathColor = self.highlightPathColor.CGColor
            } else {
                pathColor = self.pathColor.CGColor
            }

            let p0x = CGFloat(Float(self.pins[c0].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let p0y = CGFloat(Float(self.pins[c0].1) * self.scaleCoefficient + Float(self.stroke * 2))

            let p1x = CGFloat(Float(self.pins[c1].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let p1y = CGFloat(Float(self.pins[c1].1) * self.scaleCoefficient + Float(self.stroke * 2))

            CGPathMoveToPoint(connectionPathRef, nil, p0x, p0y)
            CGPathAddQuadCurveToPoint(connectionPathRef, nil, CGFloat(self.centerX), CGFloat(self.centerY), p1x, p1y)

            // CGPathCloseSubpath(connectionPathRef)
            CGContextSetLineWidth(context, CGFloat(Float(self.pathStroke) * 1.25))
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextAddPath(context, connectionPathRef)
            CGContextStrokePath(context)


            CGContextSetLineWidth(context, CGFloat(self.pathStroke))
            CGContextSetStrokeColorWithColor(context, pathColor)
            CGContextAddPath(context, connectionPathRef)
            CGContextStrokePath(context)
        }

        // stroke out the outer shape to cover the paths
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor)
        CGContextSetLineWidth(context, CGFloat(Float(self.stroke)))
        CGContextAddPath(context, shapePathRef)
        CGContextStrokePath(context)

        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func borderTile(tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        // draw outer shape
        let shapePathRef: CGMutablePathRef = CGPathCreateMutable()

        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineJoin(context, CGLineJoin.Round)

        for i in 1...(self.vertices.count - 1) {
            let x1 = CGFloat(Float(self.vertices[i].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let y1 = CGFloat(Float(self.vertices[i].1) * self.scaleCoefficient + Float(self.stroke * 2))

            if i == 1 {
                let x0 = CGFloat(Float(self.vertices[i - 1].0) * self.scaleCoefficient + Float(self.stroke * 2))
                let y0 = CGFloat(Float(self.vertices[i - 1].1) * self.scaleCoefficient + Float(self.stroke * 2))
                CGPathMoveToPoint(shapePathRef, nil, x0, y0)
            }

            CGPathAddLineToPoint(shapePathRef, nil, x1, y1)
        }

        CGPathCloseSubpath(shapePathRef)

        CGContextAddPath(context, shapePathRef)
        CGContextFillPath(context)

        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func zeroTile(tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        // draw outer shape
        let shapePathRef: CGMutablePathRef = CGPathCreateMutable()

        CGContextSetFillColorWithColor(context, UIColor(red: 0.65, green: 0.9, blue: 0.9, alpha: 1.0).CGColor)
        CGContextSetLineJoin(context, CGLineJoin.Round)

        for i in 1...(self.vertices.count - 1) {
            let x1 = CGFloat(Float(self.vertices[i].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let y1 = CGFloat(Float(self.vertices[i].1) * self.scaleCoefficient + Float(self.stroke * 2))

            if i == 1 {
                let x0 = CGFloat(Float(self.vertices[i - 1].0) * self.scaleCoefficient + Float(self.stroke * 2))
                let y0 = CGFloat(Float(self.vertices[i - 1].1) * self.scaleCoefficient + Float(self.stroke * 2))
                CGPathMoveToPoint(shapePathRef, nil, x0, y0)
            }

            CGPathAddLineToPoint(shapePathRef, nil, x1, y1)
        }

        CGPathCloseSubpath(shapePathRef)

        CGContextAddPath(context, shapePathRef)
        CGContextFillPath(context)

        // stroke out the outer shape to cover the paths
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor)
        CGContextSetLineWidth(context, CGFloat(Float(self.stroke * 2)))
        CGContextAddPath(context, shapePathRef)
        CGContextStrokePath(context)
        
        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
