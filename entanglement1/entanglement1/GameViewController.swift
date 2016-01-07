//
//  GameViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 03/01/16.
//  Copyright (c) 2016 Artem Szubowicz. All rights reserved.
//

import UIKit
import CloudKit

class GameViewController: UIViewController {
    var game: Game = Game()
    var renderer: GameRenderer? = nil
    var points: Int = 0

    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var pocketView: UIView!

    @IBAction func usePocketButtonPressed(sender: UIButton!) {
        self.game.usePocket()
        self.renderer!.update()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updatePointsLabel()

        let tapGesture = UITapGestureRecognizer(target: self, action: "tapAction:")
        self.gameView.addGestureRecognizer(tapGesture)

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: "swipeDownAction:")
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
        self.gameView.addGestureRecognizer(swipeDownGesture)

        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "swipeUpAction:")
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up
        self.gameView.addGestureRecognizer(swipeUpGesture)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.restartGame()
    }

    func updatePointsLabel() {
        self.navbar.topItem!.title = String(self.points)
    }

    func showGameOverMessage() {
        // create the alert

        let alert = UIAlertController(title: "Game Over", message: "You got \(self.points) points. Would you like to play again?", preferredStyle: UIAlertControllerStyle.Alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Again!", style: UIAlertActionStyle.Default, handler: self.restartGameHandler))
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Destructive, handler: self.exitGameHandler))

        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func restartGame() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let lx: Int = Int(screenSize.width / 20)
        let ly: Int = Int(screenSize.height / (ceil(8.0 * sqrt(3))) + 1)

        let tileSize: Int = min(lx, ly)

        self.game = Game()
        self.renderer = GameRenderer(mainView: self.gameView, pocketView: self.pocketView, game: self.game, renderingParams: RenderingParams(sideLength: tileSize))
        self.renderer!.update()
    }

    func exitGame() {
        performSegueWithIdentifier("exitGameSegue", sender: self)
    }

    func restartGameHandler(action: UIAlertAction!) {
        self.restartGame()
    }

    func exitGameHandler(action: UIAlertAction!) {
        self.exitGame()
    }

    func swipeDownAction(sender: UISwipeGestureRecognizer) {
        self.renderer!.rotateTileRight()
    }

    func swipeUpAction(sender: UISwipeGestureRecognizer) {
        self.renderer!.rotateTileLeft()
    }

    func tapAction(sender: UITapGestureRecognizer) {
        do {
            var pointsGathered: Int = 0

            try pointsGathered = self.game.pointsGathered()

            self.points += pointsGathered

            try self.game.placeTile()

            self.renderer!.update()
            self.updatePointsLabel()

            if self.game.isGameOver() {
                throw GameError.GameOver
            }
        } catch GameError.GameOver {
            self.showGameOverMessage()
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
