//
//  PlayerTurnView.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

@IBDesignable
class PlayerTurnView: UIView {
    var nameLabel: UILabel?
    var colorView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setLayout()
    }
    
    func setLayout() {
        self.backgroundColor = UIColor.clear
        
        let frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 30)
        nameLabel = UILabel(frame: frame)
        guard let nameLabel = nameLabel else { return }
        nameLabel.font = UIFont(name: "norwester", size: 20)
        nameLabel.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        nameLabel.textAlignment = .center
        
        colorView = UIView(frame: CGRect(x: 0, y: nameLabel.bounds.maxY, width: nameLabel.bounds.width, height: 8))
        guard let colorView = colorView else { return }
        colorView.backgroundColor = UIColor.clear
        colorView.layer.cornerRadius = 4
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        colorView.backgroundColor = UIColor.clear
        
        self.addSubview(nameLabel)
        self.addSubview(colorView)
    }
}
