//
//  RankingVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 01/08/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit
import CoreData

class RankingVC: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet var baseView: UIView!
    @IBOutlet var exitButton: UIButton!
    
    var playersNumber = 4
    var cdPlayers = [CDPlayer]()
    var players = [PlayerScore]()
    var playersColors = [#colorLiteral(red: 0.9490196078, green: 0.3529411765, blue: 0.3529411765, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.3215686275, blue: 0.3019607843, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0.6509803922, blue: 0.5803921569, alpha: 1), #colorLiteral(red: 1, green: 0.7843137255, blue: 0.4509803922, alpha: 1)]
    var gameHandlerDelegate: GameHandlerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            self.cdPlayers = try getContext().fetch(CDPlayer.fetchRequest())
            
            if cdPlayers.count == 0 {
                for i in 0 ..< 4 {
                    guard let cdPlayer = NSEntityDescription.insertNewObject(forEntityName: CVClass.CDPlayer.rawValue, into: getContext()) as? CDPlayer else { return }
                    cdPlayer.imageName = "\(i)"
                    cdPlayer.victories = 0
                    
                    cdPlayers.append(cdPlayer)
                    
                    getAppDelegate().saveContext()
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if players.count == 0 {
            
            var offsetX: CGFloat = 20
            let width = UIScreen.main.bounds.width / CGFloat(playersNumber) - 40
            for i in 0 ..< playersNumber {
                let frame = CGRect(x: offsetX, y: baseView.frame.midY - 5, width: width, height: 1)
                let player = PlayerScore(frame: frame)
                player.alpha = 0
                
                players.append(player)
                players[i].setImage(number: i, numOfPlayers: playersNumber)
                players[i].backgroundColor = playersColors[i]
                players[i].showRankingVictories(victories: cdPlayers[i].victories)
                players[i].layer.zPosition = -1
                
                self.view.addSubview(players[i])
                
                offsetX += frame.width + 40
                
                UIView.animate(withDuration: 0.35, animations: {
                    self.players[i].alpha = 1
                })
            }
        }
    }
    
    @IBAction func exitButtonTouched() {
        gameHandlerDelegate?.returnToMenu()
    }
}
