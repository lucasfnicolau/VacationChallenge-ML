//
//  MainMenuHelpVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
        dismissDarkTranslucentBG()
    }

    @IBAction func okButtonTouched(_ sender: Any) {
        dismissVC()
    }
}
