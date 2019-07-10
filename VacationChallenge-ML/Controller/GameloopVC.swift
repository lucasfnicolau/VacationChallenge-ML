//
//  GameloopVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

class GameloopVC: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var playerTurnView: PlayerTurnView!
    @IBOutlet var playersScoreViews: [PlayerScoreView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerTurnView.nameLabel?.text = "lucas' turn"
        playerTurnView.colorView?.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.3529411765, blue: 0.3529411765, alpha: 1)
        playersScoreViews[0].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.3529411765, blue: 0.3529411765, alpha: 1)
        playersScoreViews[0].nameLabel?.text = "lucas"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(test))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func test() {
        playersScoreViews[0].score += 20
    }
}
