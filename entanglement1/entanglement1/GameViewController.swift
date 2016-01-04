//
//  GameViewController.swift
//  entanglement1
//
//  Created by Artem Szubowicz on 03/01/16.
//  Copyright (c) 2016 Artem Szubowicz. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    let tileGenerator = TileGenerator(sideLength: 25)

    override func viewDidLoad() {
        super.viewDidLoad()

        let image = self.tileGenerator.generate(TileParams(connections: [(0, 1), (2, 3), (4, 5), (6, 7), (8, 9), (10, 11)], highlight: []))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 100, y: 300), size: image.size))
        self.view.addSubview(imageView)

        imageView.image = image
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
