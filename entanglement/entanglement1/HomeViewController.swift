//
//  HomeViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 05/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class HomeViewController: UIViewController {
    @IBAction func exitGame(segue: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBOutlet weak var loginOrStartGameButton: UIButton!

    @IBAction func startOrLogin() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.performSegueWithIdentifier("startGame", sender: self)
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
                        self.updateStartGameButtonTitle()
                    } else {
                        print("FB Shit happened: \(error)")
                    }
                })
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitApp" {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    override func viewDidLoad() {
        FBSDKLoginManager().logOut()

        self.updateStartGameButtonTitle()
    }

    func updateStartGameButtonTitle() {
        var title: String = "Start game"

        if FBSDKAccessToken.currentAccessToken() == nil {
            title = "Log in with Facebook"
        }

        self.loginOrStartGameButton.setTitle(title, forState: .Normal)
    }
}