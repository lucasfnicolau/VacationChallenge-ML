//
//  WinnerVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 28/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

class WinnerVC: UIViewController {
    var gameHandlerDelegate: GameHandlerDelegate?

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var winnerImageView: ShadowedImageView!
    @IBOutlet var winnerLabel: ShadowedLabel!
    var player = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        winnerImageView.image = UIImage(named: "\(player)")
        winnerLabel.text = "player \(player + 1) won!"
    }

    @IBAction func exit() {
        gameHandlerDelegate?.changeGameState(to: .mainMenu)
    }
}
