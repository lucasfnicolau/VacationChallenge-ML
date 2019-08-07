//
//  PlayerScore.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 17/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

@IBDesignable
class PlayerScore: UIView {
    
    var nameLabel: UILabel?
    var scoreLabel: UILabel?
    var imageView: UIImageView?
    var gameLoopDelegate: GameloopVCDelegate?
    var score: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLayout() {
        self.layer.cornerRadius = 4
        self.layer.borderColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        self.layer.borderWidth = 4
        
        var frame = CGRect(x: 0, y: 5, width: self.bounds.width, height: 30)
        nameLabel = UILabel(frame: frame)
        guard let nameLabel = nameLabel else { return }
        nameLabel.font = UIFont(name: "norwester", size: 20)
        nameLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        nameLabel.textAlignment = .center
        nameLabel.isHidden = true
        
        frame = CGRect(x: 0, y: -95, width: self.bounds.width, height: 50)
        imageView = UIImageView(frame: frame)
        guard let imageView = imageView else { return }
        imageView.contentMode = .scaleAspectFill
        
        frame = CGRect(x: 0, y: -32, width: self.bounds.width, height: 20)
        scoreLabel = UILabel(frame: frame)
        guard let scoreLabel = scoreLabel else { return }
        scoreLabel.font = UIFont(name: "norwester", size: 20)
        scoreLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        scoreLabel.textAlignment = .center
        
        self.addSubview(nameLabel)
        self.addSubview(imageView)
        self.addSubview(scoreLabel)
        
        self.score = 0
    }
    
    func adjustHeight(numOfPlayers players: Int) {
        
        if UIScreen.main.bounds.width <= 414 {
            self.imageView?.frame = CGRect(x: 0, y: -97, width: self.bounds.width, height: 0.140625 * UIScreen.main.bounds.width)
        } else {
            guard let imageView = self.imageView else { return }
            let oldThings = (imageView.frame.size.height, imageView.center)
            imageView.frame.size = SizeAdapter.getRatioSizeByBiggest(CGSize(width: 414 / players, height: 55), deviceSize: UIScreen.main.bounds.size)
            var new = oldThings.1
            new.y -= (imageView.frame.size.height - oldThings.0)
            imageView.center = new
        }
    }
    
    func addScore(_ score: Int) {
        self.score += score
        updateSize(withValue: score)
    }
    
    func setImage(number: Int, numOfPlayers players: Int) {
        if number == 1 || number == 2 {
            imageView?.frame.size.height -= 7
        }
        
        imageView?.image = UIImage(named: "\(number)")
        adjustHeight(numOfPlayers: players)
    }
    
    func showRankingVictories(victories: Int16) {
        self.score += Int(victories)
        updateSize(withValue: Int(victories) * 20)
    }
    
    func updateSize(withValue: Int) {
        let value = CGFloat(1 + withValue * 15 / 10)
        
        UIView.animate(withDuration: 1.15, delay: 0.5, options: [.curveEaseInOut], animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: -value)
            self.frame.size.height += value
            self.scoreLabel?.text = "\(self.score)" // pts"
        }, completion: { (completed) in
            if self.score >= 250 { // Alterar antes do lançamento
                self.gameLoopDelegate?.showWinner(player: Int(self.nameLabel?.text ?? "\(0)") ?? 0)
            }
        })
    }
    
    func shake() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveLinear, .beginFromCurrentState], animations: {
            self.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { (completed) in
            
            UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveLinear, .beginFromCurrentState], animations: {
                self.transform = CGAffineTransform(translationX: -10, y: 0)
            }) { (completed) in
                
                UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveLinear, .beginFromCurrentState], animations: {
                    self.transform = CGAffineTransform(translationX: 10, y: 0)
                }) { (completed) in
                    
                    UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveLinear, .beginFromCurrentState], animations: {
                        self.transform = CGAffineTransform(translationX: -10, y: 0)
                    }) { (completed) in
                        
                        UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveLinear, .beginFromCurrentState], animations: {
                            self.transform = CGAffineTransform(translationX: 0, y: 0)
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    func celebrate() {
        UIView.animate(withDuration: 0.15, delay: 1.65, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.imageView?.transform = CGAffineTransform(translationX: 0, y: 7)
        
        }) { (completed) in
            
            UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                self.imageView?.transform = CGAffineTransform(translationX: 0, y: 0)
            
            }) { (completed) in
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                    self.imageView?.transform = CGAffineTransform(translationX: 0, y: 7)
                
                }) { (completed) in
                    
                    UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                        self.imageView?.transform = CGAffineTransform(translationX: 0, y: 0)
                    
                    }, completion: nil)
                }
            }
        }
    }
}
