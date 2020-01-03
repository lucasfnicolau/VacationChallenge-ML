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
    case CDPlayer = "CDPlayer"
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

public class SizeAdapter{
    public static let iPhoneXRSize: CGSize = CGSize(width: 414, height: 896)
    
    private init(){
    }
    
    public static func getRatioSizeByHeight(_ size: CGSize, deviceSize: CGSize) -> CGSize{
        let newHeight:CGFloat = size.height * deviceSize.height / iPhoneXRSize.height
        let ratio = (size.width / size.height)
        
        let newWidth:CGFloat = newHeight * ratio
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    public static func getRatioSizeByWidth(_ size: CGSize, deviceSize: CGSize) -> CGSize{
        let newWidth:CGFloat = size.width * deviceSize.width / iPhoneXRSize.width
        let ratio = (size.height / size.width)
        
        let newHeight:CGFloat = newWidth * ratio
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    public static func getRatioSizeByBiggest(_ size: CGSize, deviceSize: CGSize) -> CGSize{
        if deviceSize.height < deviceSize.width{
            return getRatioSizeByHeight(size, deviceSize: deviceSize)
        }
        else{
            return getRatioSizeByWidth(size, deviceSize: deviceSize)
        }
    }
    
    public static func getProportionalSize(_ object: UIView, deviceSize: CGSize) -> CGSize{
        let newWidth:CGFloat = object.frame.size.width * deviceSize.width / iPhoneXRSize.width
        let newHeight:CGFloat  = object.frame.size.height * deviceSize.height / iPhoneXRSize.height
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    public static func getTrebuchetProportionalFontSize(_ fontSize: CGFloat, deviceSize: CGSize) -> CGFloat{
        
        let newFontSize:CGFloat = fontSize * deviceSize.height / iPhoneXRSize.height
        
        return newFontSize
    }
}
