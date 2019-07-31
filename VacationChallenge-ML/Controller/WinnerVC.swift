//
//  WinnerVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 28/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

class WinnerVC: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var winnerLabel: UILabel!
    var player = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        winnerLabel.text = "player \(player) won!"
    }

    @IBAction func exit() {
        self.performSegue(withIdentifier: "unwindSegueToMainMenu", sender: self)
    }
}
