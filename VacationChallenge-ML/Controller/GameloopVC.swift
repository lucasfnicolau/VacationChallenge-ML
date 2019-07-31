//
//  GameloopVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 10/07/19.
//  Copyright © 2019 Academy. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO
import UserNotifications

protocol GameloopVCDelegate {
    func showWinner(player: Int)
}

class GameloopVC: UIViewController, GameloopVCDelegate {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var playerTurnView: PlayerTurn!
    @IBOutlet var testLabel: UILabel!
    @IBOutlet var testLabel1: UILabel!
    @IBOutlet var testLabel2: UILabel!
    @IBOutlet var baseView: UIView!
    @IBOutlet var beginTurnButton: RoundedButton!
    @IBOutlet var exitButton: UIButton!
    
    var playersNumber = 2
    var players = [PlayerScore]()
    var playersColors = [#colorLiteral(red: 0.9490196078, green: 0.3529411765, blue: 0.3529411765, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.3215686275, blue: 0.3019607843, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0.6509803922, blue: 0.5803921569, alpha: 1), #colorLiteral(red: 1, green: 0.7843137255, blue: 0.4509803922, alpha: 1)]
    var currentPlayer = 0 {
        didSet {
            self.playerTurnView.nameLabel?.text = "player \(self.currentPlayer + 1) turn"
            self.playerTurnView.colorView?.backgroundColor = self.playersColors[self.currentPlayer]
            
            if players.count > 0 {
                for i in 0 ... players.count - 1 {
                    if i != currentPlayer {
                        self.players[i].fade()
                    } else {
                        self.players[i].focus()
                        self.players[i].celebrate()
                    }
                }
            }
            
            if beginTurnButton != nil {
                beginTurnButton.focus()
            }
        }
    }
    
    var easyWord = ""
    var mediumWord = "joystick"
    var hardWord = ""
    var winner = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitButton.tintColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        exitButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.beginTurnButton.alpha = 0.3
        self.beginTurnButton.isEnabled = false
        
        var tempWords = allWords
        
        self.easyWord = tempWords.randomElement() ?? ""
        tempWords.remove(at: tempWords.firstIndex(of: self.easyWord) ?? 0)
        
        self.mediumWord = tempWords.randomElement() ?? ""
        tempWords.remove(at: tempWords.firstIndex(of: self.mediumWord) ?? 0)
        
        self.hardWord = tempWords.randomElement() ?? ""
        
        self.testLabel.text = "\(self.hardWord.replacingOccurrences(of: "_", with: " ")) – 50 pts"
        self.testLabel1.text = "\(self.mediumWord.replacingOccurrences(of: "_", with: " ")) – 25 pts"
        self.testLabel2.text = "\(self.easyWord.replacingOccurrences(of: "_", with: " ")) – 10 pts"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if players.count == 0 {
        
            var offsetX: CGFloat = 20
            let width = UIScreen.main.bounds.width / CGFloat(playersNumber) - 40
            for i in 0 ..< playersNumber {
                let frame = CGRect(x: offsetX, y: baseView.frame.midY - 5, width: width, height: 1)
                let player = PlayerScore(frame: frame)
                player.alpha = 0
                
                players.append(player)
                players[i].setImage(number: i)
                players[i].backgroundColor = playersColors[i]
                players[i].addScore(0)
                players[i].layer.zPosition = -1
                players[i].gameLoopDelegate = self
                players[i].nameLabel?.text = "\(i + 1)"
                
                self.view.addSubview(players[i])
                
                offsetX += frame.width + 40
                
                UIView.animate(withDuration: 0.35, animations: {
                    self.players[i].alpha = (i == 0 ? 1 : 0.3)
                })
            }
            
            currentPlayer = 0
            
            UIView.animate(withDuration: 1.65) {
                self.beginTurnButton.alpha = 1
                self.beginTurnButton.isEnabled = true
            }
        } else {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllDeliveredNotifications()
            notificationCenter.removeAllPendingNotificationRequests()
            self.beginTurnButton.focus()
        }
    }
    
    @IBAction func beginTurn() {
        easyWord = allWords.randomElement() ?? ""
//        mediumWord = medium.randomElement() ?? ""
        hardWord = allWords.randomElement() ?? ""
    }

    // MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: Resnet50().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        // classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue(label: "Image Processing Queue").async {
            
            DispatchQueue.main.async {
                guard let results = request.results else { return }
                
                let classifications = results as! [VNClassificationObservation]
                
                if classifications.isEmpty {
                    // self.classificationLabel.text = "Nothing recognized."
                } else {
                    // Display top classifications ranked by confidence in the UI.
                    let topClassifications = classifications.prefix(10)
                    let descriptions = topClassifications.map { classification in
                        // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                        return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                    }
                    // self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
                    
                    print(descriptions)
                    
                    for description in descriptions {
                        
                        if description.lowercased().contains(self.hardWord.lowercased()) {
                            self.players[self.currentPlayer].addScore(50)
                            break
                        } else if description.lowercased().contains(self.mediumWord.lowercased()) {
                            self.players[self.currentPlayer].addScore(25)
                            break
                        } else if description.lowercased().contains(self.easyWord.lowercased()) {
                            self.players[self.currentPlayer].addScore(10)
                            break
                        } else {
                            self.players[self.currentPlayer].shake()
                        }
                    }
                    
                    self.setNewTurn()
                }
            }
        }
    }
    
    func setNewTurn() {
        self.currentPlayer = self.currentPlayer < self.playersNumber - 1 ? self.currentPlayer + 1 : 0
        
        var tempWords = allWords
        
        self.easyWord = tempWords.randomElement() ?? ""
        tempWords.remove(at: tempWords.firstIndex(of: self.easyWord) ?? 0)
        
        self.mediumWord = tempWords.randomElement() ?? ""
        tempWords.remove(at: tempWords.firstIndex(of: self.mediumWord) ?? 0)
        
        self.hardWord = tempWords.randomElement() ?? ""
        
        self.testLabel.text = "\(self.hardWord.replacingOccurrences(of: "_", with: " ")) – 50 pts"
        self.testLabel1.text = "\(self.mediumWord.replacingOccurrences(of: "_", with: " ")) – 25 pts"
        self.testLabel2.text = "\(self.easyWord.replacingOccurrences(of: "_", with: " ")) – 10 pts"
    }
    
    // MARK: - Photo Actions
    
    @IBAction func takePicture() {
        
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
//            self.beginTurnButton.fade()
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
//            self.beginTurnButton.fade()
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
//            self.beginTurnButton.fade()
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        self.setNotification(withTitle: "Your turn is over!", andBody: "Tap here to get back to the game", inSeconds: 90, usingOptions: [true, false])
        
        // PENSAR NO TEMPO
        
        self.beginTurnButton.fade()
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func showWinner(player: Int) {
        winner = player
        performSegue(withIdentifier: "goToWinnerVC", sender: self)
    }
    
    @IBAction func exitButtonTouched() {
        let alertController = UIAlertController(title: "End Game", message: "Do you really want to exit the game?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let exitAction = UIAlertAction(title: "Exit", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(exitAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension GameloopVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        //        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        imageView.image = image
        updateClassifications(for: image)
    }
    
    @IBAction func showHelp(_ sender: RoundedButton) {
        showDarkTranslucentBG(on: self)
        let mainMenuHelpVC = MainMenuHelpVC()
        mainMenuHelpVC.modalPresentationStyle = .custom
        mainMenuHelpVC.modalTransitionStyle = .crossDissolve
        self.present(mainMenuHelpVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let winnerVC = segue.destination as? WinnerVC else { return }
        winnerVC.player = winner
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension GameloopVC: UNUserNotificationCenterDelegate {
    func setNotification(withTitle title: String, andBody body: String, inSeconds seconds: TimeInterval, usingOptions options: [Bool]) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
//        let repeatAction = UNNotificationAction(identifier: Action.repeats.rawValue,
//                                                title: "Repeat",
//                                                options: [])
        
        let performSegueAction = UNNotificationAction(identifier: "myID",
                                                      title: "Perform Segue", options: [.foreground])
        
        let generalCategory = UNNotificationCategory(identifier: "generalCatID",
                                                     actions: [/*repeatAction,*/ performSegueAction],
                                                     intentIdentifiers: [],
                                                     options: [.customDismissAction])
        
        notificationCenter.setNotificationCategories([generalCategory])
        
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
                content.sound = options[0] ? UNNotificationSound.default : nil
                content.badge = options[1] ? 1 : 0
                content.categoryIdentifier = "generalCatID"
                
//                let url = Bundle.main.url(forResource: "\(self.currentPlayer)", withExtension: ".png")
//                do {
//                    let attachment = try? UNNotificationAttachment(identifier: "EndTurnNotification", url: url!, options: nil)
//                    content.attachments = [attachment!]
//                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
                let request = UNNotificationRequest(identifier: "EndTurnNotification", content: content, trigger: trigger)
                
                notificationCenter.add(request) { (error : Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
            } else {
                print("Impossível mandar notificação - permissão negada")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        
        self.dismiss(animated: true, completion: nil)
        
        setNewTurn()
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
}
