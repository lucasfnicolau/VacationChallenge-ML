//
//  ViewController.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 26/06/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit
import CoreData

class MainMenuVC: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var playersNumberLabel: UILabel!
    
    var appHasBeenOpenedBefore = false
    var defaults: UserDefaults?
    var cdPlayers = [CDPlayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfAppHasBeenOpenedBefore()
    }
    
    func checkIfAppHasBeenOpenedBefore() {
        defaults = UserDefaults()
        guard let defaults = defaults else { return }
        appHasBeenOpenedBefore = defaults.bool(forKey: "theAppHasBeenOpenedBefore")
        
        if !appHasBeenOpenedBefore {
            
            for i in 0 ..< 4 {
                guard let cdPlayer = NSEntityDescription.insertNewObject(forEntityName: CVClass.CDPlayer.rawValue, into: getContext()) as? CDPlayer else { return }
                cdPlayer.imageName = "\(i)"
                cdPlayer.victories = 0
                
                cdPlayers.append(cdPlayer)
                
                getAppDelegate().saveContext()
            }
            
            defaults.set(true, forKey: "theAppHasBeenOpenedBefore")

        } else {
            do {
                cdPlayers = try getContext().fetch(CDPlayer.fetchRequest())
            } catch let error {
                print(error)
            }
        }
    }

    @IBAction func playersNumberChanged(_ sender: UIStepper) {
        playersNumberLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func showHelp(_ sender: RoundedButton) {
        showDarkTranslucentBG(on: self)
        let mainMenuHelpVC = HelpVC()
        mainMenuHelpVC.modalPresentationStyle = .custom
        mainMenuHelpVC.modalTransitionStyle = .crossDissolve
        self.present(mainMenuHelpVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameloopVC = segue.destination as? GameloopVC {
            gameloopVC.playersNumber = Int(playersNumberLabel.text ?? "2") ?? 2
            gameloopVC.modalPresentationStyle = .fullScreen
        } else if let rankingVC = segue.destination as? RankingVC {
            rankingVC.modalPresentationStyle = .fullScreen
        }
    }
    
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) { }
}

