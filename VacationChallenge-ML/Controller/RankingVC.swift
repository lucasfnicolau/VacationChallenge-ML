//
//  RankingVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 01/08/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitButton.tintColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        exitButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)

        do {
            self.cdPlayers = try getContext().fetch(CDPlayer.fetchRequest())
            
            print(cdPlayers)
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
        self.dismiss(animated: true, completion: nil)
    }
}
