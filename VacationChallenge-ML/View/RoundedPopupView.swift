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
        self.layer.cornerRadius = 20
        self.backgroundColor = #colorLiteral(red: 0.4784313725, green: 0.6745098039, blue: 0.9333333333, alpha: 1)
    }
}
