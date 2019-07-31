//
//  UIViewExtension.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 17/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

extension UIView {
    func focus() {
        UIView.animate(withDuration: 0.30, delay: 1.65, options: [.curveEaseInOut], animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    func fade() {
        UIView.animate(withDuration: 0.30, delay: 1.65, options: [.curveEaseInOut], animations: {
            self.alpha = 0.3
        }, completion: nil)
    }
}
