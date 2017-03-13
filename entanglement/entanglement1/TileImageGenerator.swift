//
//  TileGenerator1.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import UIKit

class TileImageGenerator {
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

    func uv2xy(_ uv: (Int, Int)) -> (Int, Int) {
        let u = uv.0, v = uv.1
        let kx = Float(u - v) * (3.0 / 2.0)
        let ky = Float(u + v) * (sqrt(3.0) / 2.0)
        let x = Int(ceil(kx * Float(self.sideLength + (self.stroke * 0))))
        let y = Int(ceil(ky * Float(self.sideLength + (self.stroke * 0))))

        let cx = 9 * (self.sideLength + (self.stroke * 0))
        let cy = Int(ceil(8.0 * sqrt(3.0) * Float(self.sideLength + (self.stroke * 0))))

        return (cx + x, cy - y)
    }

    func emptyTile(_ tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let _ = UIGraphicsGetCurrentContext()

        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    func nonEmptyTile(_ tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        // draw outer shape
        let shapePathRef: CGMutablePath = CGMutablePath()

        context?.setFillColor(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).cgColor)
        context?.setLineJoin(CGLineJoin.round)

        for i in 1...(self.vertices.count - 1) {
            let x1 = CGFloat(Float(self.vertices[i].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let y1 = CGFloat(Float(self.vertices[i].1) * self.scaleCoefficient + Float(self.stroke * 2))

            if i == 1 {
                let x0 = CGFloat(Float(self.vertices[i - 1].0) * self.scaleCoefficient + Float(self.stroke * 2))
                let y0 = CGFloat(Float(self.vertices[i - 1].1) * self.scaleCoefficient + Float(self.stroke * 2))

                shapePathRef.move(to: CGPoint(x: x0, y: y0))
            }

            shapePathRef.addLine(to: CGPoint(x: x1, y: y1))
        }

        shapePathRef.closeSubpath()

        context?.addPath(shapePathRef)
        context?.fillPath()

        // draw connections
        for (c0, c1) in tileParams.connections {
            context?.setLineWidth(CGFloat(self.pathStroke))

            let connectionPathRef: CGMutablePath = CGMutablePath()
            var pathColor: CGColor

            if tileParams.mark.contains(where: { ($0.0 == c0 && $0.1 == c1) || ($0.0 == c1 && $0.1 == c0) }) {
                pathColor = self.markPathColor.cgColor
            } else if tileParams.highlight.contains(where: { ($0.0 == c0 && $0.1 == c1) || ($0.0 == c1 && $0.1 == c0) }) {
                pathColor = self.highlightPathColor.cgColor
            } else {
                pathColor = self.pathColor.cgColor
            }

            let p0x = CGFloat(Float(self.pins[c0].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let p0y = CGFloat(Float(self.pins[c0].1) * self.scaleCoefficient + Float(self.stroke * 2))

            let p1x = CGFloat(Float(self.pins[c1].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let p1y = CGFloat(Float(self.pins[c1].1) * self.scaleCoefficient + Float(self.stroke * 2))
            
            connectionPathRef.move(to: CGPoint(x: p0x, y: p0y))
            connectionPathRef.addQuadCurve(to: CGPoint(x: p1x, y: p1y), control: CGPoint(x: self.centerX, y: self.centerY))

            // CGPathCloseSubpath(connectionPathRef)
            context?.setLineWidth(CGFloat(Float(self.pathStroke) * 1.25))
            context?.setStrokeColor(UIColor.black.cgColor)
            context?.addPath(connectionPathRef)
            context?.strokePath()

            context?.setLineWidth(CGFloat(self.pathStroke))
            context?.setStrokeColor(pathColor)
            context?.addPath(connectionPathRef)
            context?.strokePath()
        }

        // stroke out the outer shape to cover the paths
        context?.setStrokeColor(self.strokeColor.cgColor)
        context?.setLineWidth(CGFloat(Float(self.stroke)))
        context?.addPath(shapePathRef)
        context?.strokePath()

        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    func borderTile(_ tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        // draw outer shape
        let shapePathRef: CGMutablePath = CGMutablePath()

        context?.setFillColor(UIColor.black.cgColor)
        context?.setLineJoin(CGLineJoin.round)

        for i in 1...(self.vertices.count - 1) {
            let x1 = CGFloat(Float(self.vertices[i].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let y1 = CGFloat(Float(self.vertices[i].1) * self.scaleCoefficient + Float(self.stroke * 2))

            if i == 1 {
                let x0 = CGFloat(Float(self.vertices[i - 1].0) * self.scaleCoefficient + Float(self.stroke * 2))
                let y0 = CGFloat(Float(self.vertices[i - 1].1) * self.scaleCoefficient + Float(self.stroke * 2))
                
                shapePathRef.move(to: CGPoint(x: x0, y: y0))
            }

            shapePathRef.addLine(to: CGPoint(x: x1, y: y1))
        }

        shapePathRef.closeSubpath()

        context?.addPath(shapePathRef)
        context?.fillPath()

        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    func zeroTile(_ tileParams: TileParams) -> UIImage {
        let size = CGSize(width: self.width, height: self.height)
        let opaque = false
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()

        // draw outer shape
        let shapePathRef: CGMutablePath = CGMutablePath()

        context?.setFillColor(UIColor(red: 0.65, green: 0.9, blue: 0.9, alpha: 1.0).cgColor)
        context?.setLineJoin(CGLineJoin.round)

        for i in 1...(self.vertices.count - 1) {
            let x1 = CGFloat(Float(self.vertices[i].0) * self.scaleCoefficient + Float(self.stroke * 2))
            let y1 = CGFloat(Float(self.vertices[i].1) * self.scaleCoefficient + Float(self.stroke * 2))

            if i == 1 {
                let x0 = CGFloat(Float(self.vertices[i - 1].0) * self.scaleCoefficient + Float(self.stroke * 2))
                let y0 = CGFloat(Float(self.vertices[i - 1].1) * self.scaleCoefficient + Float(self.stroke * 2))
                shapePathRef.move(to: CGPoint(x: x0, y: y0))
            }

            shapePathRef.addLine(to: CGPoint(x: x1, y: y1))
        }

        shapePathRef.closeSubpath()

        context?.addPath(shapePathRef)
        context?.fillPath()

        // stroke out the outer shape to cover the paths
        context?.setStrokeColor(self.strokeColor.cgColor)
        context?.setLineWidth(CGFloat(Float(self.stroke * 2)))
        context?.addPath(shapePathRef)
        context?.strokePath()
        
        // finish drawing
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
