//
//  HomeViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 05/01/16.
//  Copyright © 2016 Artem Szubowicz. All rights reserved.
//

import Foundation

import UIKit

class HomeViewController: UIViewController {
    @IBAction func exitGame(segue: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitApp" {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    override func viewDidLoad() {
    }
}