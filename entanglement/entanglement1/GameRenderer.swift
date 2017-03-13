//
//  Renderer.swift
//  entanglement
//
//  Created by Artem Szubowicz on 07/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import UIKit

public class GameRenderer {
    var game: Game
    var tileImageGenerator: TileImageGenerator
    var view: UIView
    var pocketContainerView: UIView
    var pocketTileView: UIView? = nil
    var subviews: [UIView] = []
    var nextTileView: UIView = UIView()

    init(mainView: UIView, pocketView: UIView, game: Game, renderingParams: RenderingParams) {
        self.view = mainView
        self.pocketContainerView = pocketView
        self.game = game
        self.tileImageGenerator = TileImageGenerator(renderingParams: renderingParams)
    }

    public func rotateTileRight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.nextTileView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 3.0))
            }, completion: {finished in
                self.game.rotateTileRight()
                self.update()
        })
    }

    public func rotateTileLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.nextTileView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / -3.0))
            }, completion: {finished in
                self.game.rotateTileLeft()
                self.update()
        })
    }

    public func update() {
        self.renderField()
        self.renderPocket()
    }

    private func renderPocket() {
        if self.pocketTileView != nil {
            self.pocketTileView!.removeFromSuperview()
        }

        var (x, y) = (self.pocketContainerView.frame.size.width, self.pocketContainerView.frame.height)

        let image = self.tileImageGenerator.nonEmptyTile(TileParams(connections: self.game.pocket.connections))

        x = (x / 2) - (image.size.width / 2)
        y = (y / 2) - (image.size.height / 2)

        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: image.size))

        imageView.image = image

        self.pocketTileView = imageView
        self.pocketContainerView.addSubview(imageView)
    }

    private func renderField() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }

        self.subviews.removeAll()

        for u in 0...(self.game.field.tiles.count - 1) {
            for v in 0...(self.game.field.tiles[u].count - 1) {
                let (x, y) = self.tileImageGenerator.uv2xy(u, v)
                let image = self.generate(position: (u, v))

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

    private func generateTileParams(_ position: (Int, Int)) -> TileParams {
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

        return TileParams(connections: tile.connections, highlight: highlight, mark: mark)
    }

    private func generateTileImage(tile: Tile, tileParams: TileParams) -> UIImage {
        if tile is BorderTile {
            return self.tileImageGenerator.borderTile(tileParams)
        }

        if tile is ZeroTile {
            return self.tileImageGenerator.zeroTile(tileParams)
        }

        if tile is NonEmptyTile || tile is PlaceholderTile {
            return self.tileImageGenerator.nonEmptyTile(tileParams)
        }

        return self.tileImageGenerator.emptyTile(tileParams)
    }

    private func generate(position: (Int, Int)) -> UIImage {
        let (u, v) = position

        let tileParams = self.generateTileParams(position)
        let tile = self.game.field.tiles[u][v]

        return generateTileImage(tile: tile, tileParams: tileParams)
    }
}
