//
//  GameViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 03/01/16.
//  Copyright (c) 2016 Artem Szubowicz. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var game: Game = Game()
    var renderer: GameRenderer? = nil

    /*do {
    var game = Game()

    print(game.state)

    try game.placeTile()

    print(game.state)

    try game.rotateTileRight()

    print(game.state)

    try game.placeTile()

    print(game.state)

    try game.usePocket()

    print(game.state)

    try game.placeTile()

    print(game.state)
    } catch GameError.GameOver {
        print("Game over")
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()

        self.renderer = GameRenderer(view: self.view, game: self.game, renderingParams: RenderingParams(sideLength: 15))

        self.renderer!.update()
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
