//
//  HomeViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 05/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class HomeViewController: UIViewController, UITableViewDataSource {
    var leaderboard: [NSManagedObject] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func startGameButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("startGame", sender: self)
    }

    @IBAction func loginOrLogout() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
            self.updateLoginButtonTitle()
            return
        }

        let login:FBSDKLoginManager = FBSDKLoginManager()

        login.logInWithReadPermissions(["public_profile"], fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if (error != nil) {
                FBSDKLoginManager().logOut()
            } else if (result.isCancelled) {
                FBSDKLoginManager().logOut()
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken()

                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name"], tokenString: accessToken.tokenString, version: nil, HTTPMethod: "GET")

                req.startWithCompletionHandler({ (connection, result, error: NSError!) -> Void in
                    if error == nil {
                        print("FB profile: \(result["name"] as! String)")
                        self.updateLoginButtonTitle()
                        self.updateCurrentUser(result["id"] as! String, name: result["name"] as! String)
                    } else {
                        print("FB Shit happened: \(error)")
                    }
                })
            }
        })
    }

    override func viewDidLoad() {
        self.updateLoginButtonTitle()
        self.updateLeaderboard()
    }

    override func viewDidAppear(animated: Bool) {
        self.updateLeaderboard()
        self.tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboard.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LeaderboardTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LeaderboardTableViewCell

        let entry = self.leaderboard[indexPath.row]

        cell.nameLabel.text = entry.valueForKey("name") as? String
        cell.pointsLabel.text = String(entry.valueForKey("points") as! Int)
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    func updateLeaderboard() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let leadersFetch = NSFetchRequest(entityName: "LeaderboardEntry")

        leadersFetch.sortDescriptors?.append(NSSortDescriptor(key: "points", ascending: false))

        do {
            let leaders = try managedContext.executeFetchRequest(leadersFetch) as! [NSManagedObject]

            self.leaderboard.removeAll()
            self.leaderboard.appendContentsOf(leaders)
        } catch {
            print("Failed to fetch leaders: \(error)")
        }
    }

    func updateLoginButtonTitle() {
        var title: String = "Log in with Facebook"

        if FBSDKAccessToken.currentAccessToken() != nil {
            title = "Log out"
        }

        self.loginButton.setTitle(title, forState: .Normal)
    }

    func updateCurrentUser(facebookId: String, name: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let userFetch = NSFetchRequest(entityName: "CurrentUser")

        // userFetch.predicate = NSPredicate(format: "name == '%s'", name)
        // userFetch.sortDescriptors?.append(NSSortDescriptor(key: "points", ascending: false))

        do {
            let users = try managedContext.executeFetchRequest(userFetch) as! [NSManagedObject]
            var currentUser: NSManagedObject

            if users.count > 0 {
                currentUser = users.first!
            } else {
                currentUser = NSEntityDescription.insertNewObjectForEntityForName("CurrentUser", inManagedObjectContext: managedContext)
            }

            currentUser.setValue(name, forKey: "name")
            currentUser.setValue(facebookId, forKey: "facebook_id")
        } catch {
            print("Failed to fetch current user: \(error)")
        }

        appDelegate.saveContext()
    }
}