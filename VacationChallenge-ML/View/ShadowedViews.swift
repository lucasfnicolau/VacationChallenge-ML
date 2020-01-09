//
//  ShadowedView.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 09/01/20.
//  Copyright © 2020 Academy. All rights reserved.
//

import UIKit

func setUniversalViewLayout(for view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowRadius = 10
    view.layer.shadowOpacity = 0.7
    view.layer.shadowOffset = .zero
}

class ShadowedView: UIView {

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
        setUniversalViewLayout(for: self)
    }

}

class ShadowedLabel: UILabel {

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
        setUniversalViewLayout(for: self)
    }

}

class ShadowedButton: UIButton {

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
        setUniversalViewLayout(for: self)
    }
}

class ShadowedStepper: UIStepper {

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
        setUniversalViewLayout(for: self)
    }
}

class ShadowedImageView: UIImageView {

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
        setUniversalViewLayout(for: self)
    }
}
