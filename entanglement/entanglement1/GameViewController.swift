//
//  GameViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 03/01/16.
//  Copyright (c) 2016 Artem Szubowicz. All rights reserved.
//

import UIKit
import CoreData

class GameViewController: UIViewController {
    var game: Game = Game()
    var renderer: GameRenderer? = nil
    var points: Int = 0

    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var pocketView: UIView!

    @IBAction func usePocketButtonPressed(_ sender: UIButton!) {
        self.game.usePocket()
        self.renderer!.update()
    }

    @IBAction func exitGameAction(_ sender: AnyObject) {
        self.exitGame()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updatePointsLabel()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapAction(_:)))
        self.gameView.addGestureRecognizer(tapGesture)

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipeDownAction(_:)))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.down
        self.gameView.addGestureRecognizer(swipeDownGesture)

        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipeUpAction(_:)))
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.up
        self.gameView.addGestureRecognizer(swipeUpGesture)

        self.setDailyNotification()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.restartGame()
    }

    func setDailyNotification() {
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = NSLocalizedString("Daily_notification_message", comment: "Don't forget to play Entanglement today!") // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.repeatInterval = NSCalendar.Unit.day // todo item due date (when notification will be fired)
        // notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        // notification.userInfo = ["UUID": item.UUID, ] // assign a unique identifier to the notification so that we can retrieve it later
        notification.category = "TODO_CATEGORY"
        UIApplication.shared.scheduleLocalNotification(notification)
    }

    func updatePointsLabel() {
        self.navbar.topItem!.title = String(self.points)
    }

    func showGameOverMessage() {
        self.exitGame()
    }

    func restartGame() {
        let screenSize: CGRect = UIScreen.main.bounds
        let lx: Int = Int(screenSize.width / 20)
        let ly: Int = Int(screenSize.height / (ceil(8.0 * sqrt(3))) + 1)

        let tileSize: Int = min(lx, ly)

        self.game = Game()
        self.renderer = GameRenderer(mainView: self.gameView, pocketView: self.pocketView, game: self.game, renderingParams: RenderingParams(sideLength: tileSize, stroke: tileSize / 10, pathStroke: tileSize / 4))
        self.renderer!.update()
    }

    func exitGame() {
        self.dismiss(animated: true, completion: nil)
    }

    func restartGameHandler(_ action: UIAlertAction!) {
        self.restartGame()
    }

    func exitGameHandler(_ action: UIAlertAction!) {
        self.exitGame()
    }

    func swipeDownAction(_ sender: UISwipeGestureRecognizer) {
        self.renderer!.rotateTileRight()
    }

    func swipeUpAction(_ sender: UISwipeGestureRecognizer) {
        self.renderer!.rotateTileLeft()
    }

    func tapAction(_ sender: UITapGestureRecognizer) {
        do {
            var pointsGathered: Int = 0

            try pointsGathered = self.game.pointsGathered()

            self.points += pointsGathered

            try self.game.placeTile()

            self.renderer!.update()
            self.updatePointsLabel()

            if self.game.isGameOver() {
                throw GameError.gameOver
            }
        } catch GameError.gameOver {
            self.showGameOverMessage()
        } catch {
            print("Shit happens...")
        }
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
