//
//  Helpers.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit
import CoreData

var darkTranslucentBG: UIView?

enum Difficulty: Int16 {
    case easy = 0
    case medium = 1
    case hard = 2
}

enum CVClass: String {
    case CVObject = "CVObject"
}

enum Image: String {
    case cameraFrame = "camera_frame"
    case startButton = "start_button"
    case help = "help"
}

func getImage(_ image: Image) -> UIImage? {
    return UIImage(named: image.rawValue)
}

func showDarkTranslucentBG(on vc: UIViewController) {
    darkTranslucentBG = UIView(frame: vc.view.frame)
    darkTranslucentBG?.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 0.85)
    darkTranslucentBG?.alpha = 0
    
    guard let darkTranslucentBG = darkTranslucentBG else { return }
    vc.view.addSubview(darkTranslucentBG)
    
    UIView.animate(withDuration: 0.2) {
        darkTranslucentBG.alpha = 1
    }
}

func dismissDarkTranslucentBG() {
    UIView.animate(withDuration: 0.2, animations: {
        darkTranslucentBG?.alpha = 0
    }) { (completed) in
        darkTranslucentBG?.removeFromSuperview()
    }
}

func getAppDelegate() -> AppDelegate {
    return (UIApplication.shared.delegate as? AppDelegate) ?? AppDelegate()
}

func getContext() -> NSManagedObjectContext {
    return getAppDelegate().persistentContainer.viewContext
}
