//
//  Renderer.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import UIKit

open class GameRenderer {
    var game: Game
    var tileGenerator: TileGenerator
    var view: UIView
    var pocketContainerView: UIView
    var pocketTileView: UIView? = nil
    var subviews: [UIView] = []
    var nextTileView: UIView = UIView()

    init(mainView: UIView, pocketView: UIView, game: Game, renderingParams: RenderingParams) {
        self.view = mainView
        self.pocketContainerView = pocketView
        self.game = game
        self.tileGenerator = TileGenerator(renderingParams: renderingParams)
    }

    open func rotateTileRight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.nextTileView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 3.0))
            }, completion: {finished in
                self.game.rotateTileRight()
                self.update()
        })
    }

    open func rotateTileLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.nextTileView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / -3.0))
            }, completion: {finished in
                self.game.rotateTileLeft()
                self.update()
        })
    }

    open func update() {
        self.renderField()
        self.renderPocket()
    }

    fileprivate func renderPocket() {
        if self.pocketTileView != nil {
            self.pocketTileView!.removeFromSuperview()
        }

        var (x, y) = (self.pocketContainerView.frame.size.width, self.pocketContainerView.frame.height)

        let image = self.tileGenerator.nonEmptyTile(TileParams(connections: self.game.pocket.connections))

        x = (x / 2) - (image.size.width / 2)
        y = (y / 2) - (image.size.height / 2)

        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: image.size))

        imageView.image = image

        self.pocketTileView = imageView
        self.pocketContainerView.addSubview(imageView)
    }

    fileprivate func renderField() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }

        self.subviews.removeAll()

        for u in 0...(self.game.field.tiles.count - 1) {
            for v in 0...(self.game.field.tiles[u].count - 1) {
                let (x, y) = self.tileGenerator.uv2xy(u, v)
                let image = self.generate((u, v))

                let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: image.size))

                imageView.image = image

                self.subviews.append(imageView)

                if u == self.game.field.nextPlace.0 && v == self.game.field.nextPlace.1 && !self.game.isGameOver() {
                    self.nextTileView = imageView
                }

                self.view.addSubview(imageView)
            }
        }
    }

    fileprivate func generate(_ position: (Int, Int)) -> UIImage {
        let u = position.0, v = position.1
        var tile: Tile

        if u == self.game.field.nextPlace.0 && v == self.game.field.nextPlace.1 && !self.game.isGameOver() {
            tile = self.game.nextTile
        } else {
            tile = self.game.field.tiles[u][v]
        }

        var pathItems: [PathItem] = self.game.field.path.items.filter({ $0.u == u && $0.v == v})
        var mark: [(Int, Int)] = []

        for p in pathItems {
            mark.append((p.input, p.output))
        }

        var highlight: [(Int, Int)] = []

        do {
            var tmpPath: Path
            try (tmpPath, (_, _)) = self.game.field.findFuturePath(self.game.nextTile)

            pathItems = tmpPath.items.filter({ $0.u == u && $0.v == v })

            for p in pathItems {
                highlight.append((p.input, p.output))
            }
        } catch GameError.gameOver {
        } catch {
        }

        let tileParams = TileParams(connections: tile.connections, highlight: highlight, mark: mark)

        if tile is BorderTile {
            return self.tileGenerator.borderTile(tileParams)
        }

        if tile is ZeroTile {
            return self.tileGenerator.zeroTile(tileParams)
        }
        
        if tile is NonEmptyTile || tile is PlaceholderTile {
            return self.tileGenerator.nonEmptyTile(tileParams)
        }
        
        return self.tileGenerator.emptyTile(tileParams)
    }
}
