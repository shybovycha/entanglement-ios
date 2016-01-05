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

    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: "tapAction:")
        self.view.addGestureRecognizer(gesture)

        self.restartGame()
    }

    func showGameOverMessage() {
        // create the alert
        let alert = UIAlertController(title: "Game Over", message: "Would you like to play again?", preferredStyle: UIAlertControllerStyle.Alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Again!", style: UIAlertActionStyle.Default, handler: self.restartGameHandler))
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Destructive, handler: self.exitGameHandler))

        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func restartGame() {
        self.game = Game()
        self.renderer = GameRenderer(view: self.view, game: self.game, renderingParams: RenderingParams(sideLength: 15))
        self.renderer!.update()
    }

    func exitGame() {
        exit(0)
    }

    func restartGameHandler(action: UIAlertAction!) {
        self.restartGame()
    }

    func exitGameHandler(action: UIAlertAction!) {
        self.exitGame()
    }

    func tapAction(sender: UITapGestureRecognizer) {
        do {
            try self.game.placeTile()

            if self.game.isGameOver() {
                self.showGameOverMessage()
            }

            self.renderer!.update()
        } catch GameError.GameOver {
            print("Game over!")
        } catch {
            print("Shit happens...")
        }
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
