//
//  GameloopVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO
import UserNotifications

protocol GameloopVCDelegate {
    func showWinner(player: Int)
}

class GameloopVC: UIViewController, GameloopVCDelegate {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var playerTurnView: PlayerTurn!
    @IBOutlet var easyWordLabel: UILabel!
    @IBOutlet var mediumWordLabel: UILabel!
    @IBOutlet var hardWordLabel: UILabel!
    @IBOutlet var baseView: UIView!
    @IBOutlet var beginTurnButton: RoundedButton!
    @IBOutlet var exitButton: UIButton!

    var gameHandlerDelegate: GameHandlerDelegate?
    var cdPlayers = [CDPlayer]()
    var playersNumber = 2
    var players = [PlayerScore]()
    var playersColors = [#colorLiteral(red: 0.9490196078, green: 0.3529411765, blue: 0.3529411765, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.3215686275, blue: 0.3019607843, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0.6509803922, blue: 0.5803921569, alpha: 1), #colorLiteral(red: 1, green: 0.7843137255, blue: 0.4509803922, alpha: 1)]
    var easyWord = ""
    var mediumWord = ""
    var hardWord = ""
    var winner = 0
    var turnTimer: Timer!
    var currentPlayer = 0 {
        didSet {
            self.playerTurnView.nameLabel?.text = "player \(self.currentPlayer + 1) turn"
            self.playerTurnView.colorView?.backgroundColor = self.playersColors[self.currentPlayer]

            if players.count > 0 {
                for i in 0 ... players.count - 1 {
                    if i != currentPlayer {
                        self.players[i].fade()
                    } else {
                        self.players[i].focus()
                        self.players[i].celebrate()
                    }
                }
            }

            if beginTurnButton != nil {
                beginTurnButton.focus()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitButton.tintColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        self.beginTurnButton.alpha = 0.3
        self.beginTurnButton.isEnabled = false

        loadWords()
        
        do {
            cdPlayers = try getContext().fetch(CDPlayer.fetchRequest())
        } catch let error {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if players.count == 0 {
            createPlayers()
        } else {
            self.beginTurnButton.focus()
        }
    }

    /**
     Loads the three words to be used in the first turn of the game.

     - Version:
     1.0
     */
    func loadWords() {
        var tempWords = allWords

        self.easyWord = (tempWords.randomElement() ?? "").lowercased()
        tempWords.remove(at: tempWords.firstIndex(of: self.easyWord) ?? 0)

        self.mediumWord = (tempWords.randomElement() ?? "").lowercased()
        tempWords.remove(at: tempWords.firstIndex(of: self.mediumWord) ?? 0)

        self.hardWord = (tempWords.randomElement() ?? "").lowercased()

        self.easyWordLabel.text = "\(self.hardWord) – 50 pts"
        self.mediumWordLabel.text = "\(self.mediumWord) – 25 pts"
        self.hardWordLabel.text = "\(self.easyWord) – 10 pts"
    }

    /**
     Creates the players and show them on the screen.

     - Version:
     1.0
     */
    func createPlayers() {
        var offsetX: CGFloat = 20
        let width = UIScreen.main.bounds.width / CGFloat(playersNumber) - 40
        for i in 0 ..< playersNumber {
            let frame = CGRect(x: offsetX, y: baseView.frame.midY - 5, width: width, height: 1)
            let player = PlayerScore(frame: frame)
            player.alpha = 0

            players.append(player)
            players[i].setImage(number: i, numOfPlayers: playersNumber)
            players[i].backgroundColor = playersColors[i]
            players[i].addScore(0)
            players[i].layer.zPosition = -1
            players[i].gameLoopDelegate = self
            players[i].nameLabel?.text = "\(i + 1)"

            self.view.addSubview(players[i])

            offsetX += frame.width + 40

            UIView.animate(withDuration: 0.35, animations: {
                self.players[i].alpha = (i == 0 ? 1 : 0.3)
            })
        }

        currentPlayer = 0

        UIView.animate(withDuration: 1.65) {
            self.beginTurnButton.alpha = 1
            self.beginTurnButton.isEnabled = true
        }
    }

    /**
     Passes the turn to the next player.

     - Version:
     1.0
     */
    func setNewTurn() {
        if players[currentPlayer].score >= Constants.finalScore.rawValue {
            showWinner(player: currentPlayer)

        } else {
            self.currentPlayer = self.currentPlayer < self.playersNumber - 1 ? self.currentPlayer + 1 : 0

            var tempWords = allWords

            self.easyWord = (tempWords.randomElement() ?? "").lowercased()
            tempWords.remove(at: tempWords.firstIndex(of: self.easyWord) ?? 0)

            self.mediumWord = (tempWords.randomElement() ?? "").lowercased()
            tempWords.remove(at: tempWords.firstIndex(of: self.mediumWord) ?? 0)

            self.hardWord = (tempWords.randomElement() ?? "").lowercased()

            self.easyWordLabel.text = "\(self.hardWord) – 50 pts"
            self.mediumWordLabel.text = "\(self.mediumWord) – 25 pts"
            self.hardWordLabel.text = "\(self.easyWord) – 10 pts"
        }
    }

    /**
     Opens the view controller that recongizes the objects on the screen.

     - parameters:
        - sender: The touched RoundedButton.

     - Version:
     1.0
     */
    @IBAction func beginTurn(_ sender: RoundedButton) {
        gameHandlerDelegate?.beginTurn(for: [easyWord, mediumWord, hardWord],
                                       andCurrentPlayer: currentPlayer)
    }

    /**
     Ends the game and shows the winner.

     - parameters:
        - player: The player that won the match.

     - Version:
     1.0
     */
    func showWinner(player: Int) {
        cdPlayers[player].victories += 1
        getAppDelegate().saveContext()
        
        winner = player
        gameHandlerDelegate?.showWinner(player: player)
    }

    /**
     Return to the Main Menu.

     - Version:
     1.0
     */
    @IBAction func exitButtonTouched() {
        let alertController = UIAlertController(title: "End Game", message: "Do you really want to exit the game?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let exitAction = UIAlertAction(title: "Exit", style: .destructive) { (action) in
            self.gameHandlerDelegate?.changeGameState(to: .mainMenu)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(exitAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension GameloopVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /**
     Show a help to the player.

     - parameters:
        - sender: The touched RoundedButton.

     - Version:
     1.0
     */
    @IBAction func showHelp(_ sender: RoundedButton) {
        showDarkTranslucentBG(on: self)
        let mainMenuHelpVC = HelpVC()
        mainMenuHelpVC.modalPresentationStyle = .custom
        mainMenuHelpVC.modalTransitionStyle = .crossDissolve
        self.present(mainMenuHelpVC, animated: true, completion: nil)
    }
}
