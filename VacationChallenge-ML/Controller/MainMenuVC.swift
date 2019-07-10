//
//  ViewController.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 26/06/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

class MainMenuVC: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var playersNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playersNumberChanged(_ sender: UIStepper) {
        playersNumberLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func showHelp(_ sender: RoundedButton) {
        showDarkTranslucentBG(on: self)
        let mainMenuHelpVC = MainMenuHelpVC()
        mainMenuHelpVC.modalPresentationStyle = .custom
        mainMenuHelpVC.modalTransitionStyle = .crossDissolve
        self.present(mainMenuHelpVC, animated: true, completion: nil)
    }
    
}

