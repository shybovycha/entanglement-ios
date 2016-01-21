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

    @IBAction func usePocketButtonPressed(sender: UIButton!) {
        self.game.usePocket()
        self.renderer!.update()
    }

    @IBAction func exitGameAction(sender: AnyObject) {
        self.exitGame()
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

        self.setDailyNotification()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.restartGame()
    }

    func setDailyNotification() {
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = NSLocalizedString("Daily_notification_message", comment: "Don't forget to play Entanglement today!") // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.repeatInterval = NSCalendarUnit.Day // todo item due date (when notification will be fired)
        // notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        // notification.userInfo = ["UUID": item.UUID, ] // assign a unique identifier to the notification so that we can retrieve it later
        notification.category = "TODO_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func updatePointsLabel() {
        self.navbar.topItem!.title = String(self.points)
    }

    func showGameOverMessage() {
        self.exitGame()
    }

    func restartGame() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let lx: Int = Int(screenSize.width / 20)
        let ly: Int = Int(screenSize.height / (ceil(8.0 * sqrt(3))) + 1)

        let tileSize: Int = min(lx, ly)

        self.game = Game()
        self.renderer = GameRenderer(mainView: self.gameView, pocketView: self.pocketView, game: self.game, renderingParams: RenderingParams(sideLength: tileSize, stroke: tileSize / 10, pathStroke: tileSize / 4))
        self.renderer!.update()
    }

    func exitGame() {
        self.saveResult()
        self.dismissViewControllerAnimated(true, completion: nil)
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

    func saveResult() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let userFetch = NSFetchRequest(entityName: "CurrentUser")

        var name: String = NSLocalizedString("Anonymous_player_name", comment: "Anonymous Player")

        do {
            let users = try managedContext.executeFetchRequest(userFetch) as! [NSManagedObject]

            if users.count > 0 {
                name = users.first!.valueForKey("name") as! String
            }
        } catch {
            print("Failed to fetch current user: \(error)")
        }

        let leaderFetch = NSFetchRequest(entityName: "LeaderboardEntry")

        leaderFetch.predicate = NSPredicate(format: "name = %@", name)
        leaderFetch.sortDescriptors?.append(NSSortDescriptor(key: "points", ascending: false))

        do {
            let leaders = try managedContext.executeFetchRequest(leaderFetch) as! [NSManagedObject]

            var leader: NSManagedObject

            if leaders.count > 0 {
                leader = leaders.first!
            } else {
                let entity = NSEntityDescription.entityForName("LeaderboardEntry", inManagedObjectContext:managedContext)

                leader = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                leader.setValue(0, forKey: "points")
                leader.setValue(name, forKey: "name")
            }

            if (leader.valueForKey("points") as! Int) < self.points {
                leader.setValue(self.points, forKey: "points")
            }

            appDelegate.saveContext()
        } catch {
            print("Failed to update leaderboard: \(error)")
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
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
