//
//  RoundedPopupView.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedPopupView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setLayout()
    }
    
    func setLayout() {
//        self.layer.cornerRadius = self.bounds.height / 8
        self.layer.cornerRadius = 20
        self.backgroundColor = #colorLiteral(red: 0.3921568627, green: 0.7490196078, blue: 0.7098039216, alpha: 1)
    }
}
