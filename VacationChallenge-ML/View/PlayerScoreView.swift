//
//  PlayerScoreView.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

@IBDesignable
class PlayerScoreView: UIView {

    var nameLabel: UILabel?
    var scoreLabel: UILabel?
    var score: Int = 0 {
        didSet {
            setNeedsDisplay()
            updateSize()
            self.scoreLabel?.text = "\(score) pts"
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
    
    func setLayout() {
        self.layer.cornerRadius = 4
        self.layer.borderColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        self.layer.borderWidth = 4
        
        let frame = CGRect(x: 0, y: 5, width: self.bounds.width, height: 30)
        nameLabel = UILabel(frame: frame)
        guard let nameLabel = nameLabel else { return }
        nameLabel.font = UIFont(name: "norwester", size: 20)
        nameLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        nameLabel.textAlignment = .center
        
        scoreLabel = UILabel(frame: CGRect(x: 0, y: -25, width: self.bounds.width, height: 20))
        guard let scoreLabel = scoreLabel else { return }
        scoreLabel.font = UIFont(name: "norwester", size: 20)
        scoreLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        scoreLabel.textAlignment = .center
        
        self.addSubview(nameLabel)
        self.addSubview(scoreLabel)
        
        self.score = 0
    }
    
    func updateSize() {
        let value = CGFloat(1 + self.score / 10)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: -value)
            self.frame.size.height += value
        }, completion: nil)
    }
}
