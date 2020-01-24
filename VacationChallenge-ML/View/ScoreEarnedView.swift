//
//  ScoreEarnedView.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 22/01/20.
//  Copyright © 2020 Academy. All rights reserved.
//

import UIKit

class ScoreEarnedView: UIView {
    var label: ShadowedLabel = {
        let label = ShadowedLabel()
        label.font = UIFont(name: "norwester", size: 28)
        label.textColor = .green
        label.textAlignment = .center
        return label
    }()

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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
    }

    func setLayout() {
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        self.alpha = 0
    }

    func show(score: Int, completion: @escaping () -> Void) {
        label.text = "+\(score)"

        UIView.animate(withDuration: 1.0, animations: {
            self.alpha = 1
        }) { (_) in

            UIView.animate(withDuration: 1.0, delay: 0.5, options: [], animations: {
                self.alpha = 0
            }) { (_) in
                
                completion()
            }
        }
    }
}
