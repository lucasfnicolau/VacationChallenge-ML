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
    var cvObjects = [CVObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfAppHasBeenOpenedBefore()
    }
    
    func checkIfAppHasBeenOpenedBefore() {
        defaults = UserDefaults()
        guard let defaults = defaults else { return }
        appHasBeenOpenedBefore = defaults.bool(forKey: "theAppHasBeenOpenedBefore")
        
        print(appHasBeenOpenedBefore)
        
        if !appHasBeenOpenedBefore {
            
            for i in 0 ..< easy.count {
                guard let obj = NSEntityDescription.insertNewObject(forEntityName: CVClass.CVObject.rawValue, into: getContext()) as? CVObject else { return }
                obj.objName = easy[i]
                obj.difficulty = Difficulty.easy.rawValue
                
                getAppDelegate().saveContext()
            }
            
            for i in 0 ..< medium.count {
                guard let obj = NSEntityDescription.insertNewObject(forEntityName: CVClass.CVObject.rawValue, into: getContext()) as? CVObject else { return }
                obj.objName = medium[i]
                obj.difficulty = Difficulty.medium.rawValue
                
                getAppDelegate().saveContext()
            }
            
            for i in 0 ..< hard.count {
                guard let obj = NSEntityDescription.insertNewObject(forEntityName: "CVObject", into: getContext()) as? CVObject else { return }
                obj.objName = hard[i]
                obj.difficulty = Difficulty.hard.rawValue
                
                getAppDelegate().saveContext()
            }
            
            defaults.set(true, forKey: "theAppHasBeenOpenedBefore")

        } else {
            do {
                cvObjects = try getContext().fetch(CVObject.fetchRequest())
                print(cvObjects)
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
        let mainMenuHelpVC = MainMenuHelpVC()
        mainMenuHelpVC.modalPresentationStyle = .custom
        mainMenuHelpVC.modalTransitionStyle = .crossDissolve
        self.present(mainMenuHelpVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameloopVC = segue.destination as? GameloopVC {
            gameloopVC.playersNumber = Int(playersNumberLabel.text ?? "2") ?? 2
        }
    }
}

