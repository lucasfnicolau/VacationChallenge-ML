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

class GameloopVC: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var playerTurnView: PlayerTurn!
    @IBOutlet var testLabel: UILabel!
    @IBOutlet var baseView: UIView!
    @IBOutlet var beginTurnButton: RoundedButton!
    
    var playersNumber = 2
    var players = [PlayerScore]()
    var playersColors = [#colorLiteral(red: 0.9490196078, green: 0.3529411765, blue: 0.3529411765, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.3215686275, blue: 0.3019607843, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0.6509803922, blue: 0.5803921569, alpha: 1), #colorLiteral(red: 0.3450980392, green: 0.4823529412, blue: 0.4980392157, alpha: 1)]
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
                    }
                }
            }
            
            if beginTurnButton != nil {
                beginTurnButton.focus()
            }
        }
    }
    
    var lowScore = ["remote control", "mic", "door"]
    var r0 = ""
    var r1 = ""
    var highScore = ["joystick"]//, "dog", "glasses"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if players.count == 0 {
        
            var offsetX: CGFloat = 20
            let width = UIScreen.main.bounds.width / CGFloat(playersNumber) - 40
            for i in 0 ..< playersNumber {
                let frame = CGRect(x: offsetX, y: baseView.frame.midY - 40, width: width, height: 50)
                let player = PlayerScore(frame: frame)
                player.alpha = 0
                
                players.append(player)
                players[i].backgroundColor = playersColors[i]
                players[i].layer.zPosition = -1
                
                self.view.addSubview(players[i])
                
                offsetX += frame.width + 40
                
                UIView.animate(withDuration: 0.35, animations: {
                    self.players[i].alpha = (i == 0 ? 1 : 0.5)
                })
            }
            
            currentPlayer = 0
        }
    }
    
    @IBAction func beginTurn() {
        r0 = lowScore.randomElement() ?? ""
        r1 = highScore.randomElement() ?? ""
        print("\n\(r0) - 20 pts")
        print("\(r1) - 50 pts\n")
    }

    // MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: MobileNetV2().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
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
        DispatchQueue.main.async {
            guard let results = request.results else {
                // self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                // self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                // self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
                
                print(descriptions)
                
                for description in descriptions {
                
                    if description.contains(self.r1) {
                        self.players[self.currentPlayer].score += 100
                        print("\nr1 - OK\n")
                        break
                    } else if description.contains(self.r0) {
                        self.players[self.currentPlayer].score += 20
                        print("\nr0 - OK\n")
                        break
                    } else {
                        self.players[self.currentPlayer].shake()
                    }
                }
                
                self.currentPlayer = self.currentPlayer < self.playersNumber - 1 ? self.currentPlayer + 1 : 0
            }
        }
    }
    
    // MARK: - Photo Actions
    
    @IBAction func takePicture() {
        beginTurnButton.fade()
        
        r0 = lowScore.randomElement() ?? ""
        r1 = highScore.randomElement() ?? ""
        print("\n\(r0) - 20 pts")
        print("\(r1) - 50 pts\n")
        
        testLabel.text = "\(r1) – 100 pts"
        
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
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
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

