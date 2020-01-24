//
//  RoundedButton.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: ShadowedButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setLayout()
    }
    
    override func setLayout() {
        super.layer.borderColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        super.layer.borderWidth = 4
        self.layer.cornerRadius = self.bounds.height / 2
        self.setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1), for: .highlighted)
        self.setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1), for: .focused)
        self.setTitleColor(#colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1), for: .selected)
        self.imageView?.contentMode = .scaleAspectFit

        super.setLayout()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        self.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
//        self.titleLabel?.textColor = #colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        self.backgroundColor = #colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1)
//        self.titleLabel?.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        self.backgroundColor = #colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1)
//        self.titleLabel?.textColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
//    }
}
