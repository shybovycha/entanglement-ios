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

class HomeViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func startGameButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "startGame", sender: self)
    }
}
