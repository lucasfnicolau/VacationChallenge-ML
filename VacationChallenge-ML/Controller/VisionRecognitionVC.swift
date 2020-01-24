//
//  VisionRecognitionVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 03/01/20.
//  Copyright © 2020 Academy. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class VisionRecognitionVC: UIViewController { // CameraVideoVC {

    var cameraVideoVC: CameraVideoVC!
    private var detectionOverlay: CALayer? = nil
    var gameHandlerDelegate: GameHandlerDelegate?
    var score = 0
    var currentPlayer = 0
    var currentTime = 61
    var turnTimer: Timer?
    var words: [String] = []
    var correctObjectsRecognized = [false, false, false]
    private var requests = [VNRequest]()
    var playerImageView: UIImageView?
    var timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: Font.norwester.rawValue, size: 28)
        return label
    }()
    var closeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setBackgroundImage(UIImage(named: "close"), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }

    /**
     Configures the start of a turn, reseting the timer and setting the top view elements.

     - Version:
     1.0
     */
    func startTurn() {
        setupLayers()
        correctObjectsRecognized = [false, false, false]
        score = 0
        timerLabel.text = "60"
        currentTime = 61
        setTopViewElements()
        turnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        turnTimer?.fire()
    }

    /**
     Setup the Vision framework by choosing what ML Model will be used and by starting the image recognition features.

     - Version:
     1.0
     */
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil

        guard let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionRecognitionVC", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }

        return error
    }

    /**
     Draw on the view the boxes around the elements recognized by the ML Model.

     - parameters:
        - results: An array containing all results given by the model.

     - Version:
     1.0
     */
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay?.sublayers = nil // remove all the old recognized objects

        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(cameraVideoVC.bufferSize.width), Int(cameraVideoVC.bufferSize.height))

            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds, identifier: topLabelObservation.identifier)
            detectionOverlay?.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let exifOrientation = cameraVideoVC.exifOrientationFromDeviceOrientation()

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }

    /**
     Call all of the needed setup functions.

     - Version:
     1.0
     */
    func setupAVCapture() {
        setupLayers()
        updateLayerGeometry()
        setupVision()
    }

    /**
     Configure the layers that will be used to show all the renderings of the observations.

     - Version:
     1.0
     */
    func setupLayers() {
        if detectionOverlay == nil {
            detectionOverlay = CALayer() // container layer that has all the renderings of the observations
            detectionOverlay?.name = "DetectionOverlay"
            detectionOverlay?.bounds = CGRect(x: 0.0,
                                             y: 0.0,
                                             width: cameraVideoVC.bufferSize.width,
                                             height: cameraVideoVC.bufferSize.height)

            guard let rootLayer = cameraVideoVC.rootLayer else { return }
            detectionOverlay?.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
            rootLayer.addSublayer(detectionOverlay ?? CALayer())
        }
    }

    /**
     Create the elements that will be displayet at the top of the view. These elements are the current player image view, the timer label and the close button. This function also fires the turn timer after it creation.

     - Version:
     1.0
     */
    func setTopViewElements() {
        playerImageView?.removeFromSuperview()
        timerLabel.removeFromSuperview()
        closeButton.removeFromSuperview()

        playerImageView = UIImageView(image: UIImage(named: "\(currentPlayer)"))
        guard let playerImageView = playerImageView else { return }
        guard let image = playerImageView.image else { return }
        let size = (image.size.width, image.size.height)

        self.view.addSubview(playerImageView)
        self.view.addSubview(timerLabel)
        self.view.addSubview(closeButton)

        playerImageView.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
//            playerImageView.topAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            playerImageView.widthAnchor.constraint(equalToConstant: size.0 * 0.95),
            playerImageView.heightAnchor.constraint(equalToConstant: size.1 * 0.95),

            timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 45),
            closeButton.heightAnchor.constraint(equalToConstant: 45),

            playerImageView.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
        ])

        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    /**
     This function handles the turn timer behaviour, updating the timer label. After the time is over, this view controller will be dismissed.

     - Version:
     1.0
     */
    @objc func timerHandler() {
        currentTime -= 1
        self.timerLabel.text = "\(currentTime)"

        if currentTime <= 0 {
            turnTimer?.invalidate()
            turnTimer = nil
            detectionOverlay?.removeFromSuperlayer()
            detectionOverlay = nil
            gameHandlerDelegate?.endTurn(withScore: score)
        }
    }

    /**
     Dismiss this view controller.

     - Version:
     1.0
     */
    @objc func close() {
        let alertController = UIAlertController(title: "End Turn", message: "Do you really want to abandon your turn?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let exitAction = UIAlertAction(title: "Exit", style: .destructive) { (action) in
            self.turnTimer?.invalidate()
            self.detectionOverlay?.removeFromSuperlayer()
            self.detectionOverlay = nil
            self.gameHandlerDelegate?.endTurn(withScore: self.score)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(exitAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func updateLayerGeometry() {
        guard let rootLayer = cameraVideoVC.rootLayer else { return }
        let bounds = rootLayer.bounds
        var scale: CGFloat

        let xScale: CGFloat = bounds.size.width / cameraVideoVC.bufferSize.height
        let yScale: CGFloat = bounds.size.height / cameraVideoVC.bufferSize.width

        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay?.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay?.position = CGPoint (x: bounds.midX, y: bounds.midY)

        CATransaction.commit()
    }

    /**
     Create a rounded rectangle with colored borders to highlight the recognized object.
     If the recognized object is one of the words from the current turn, the rectangle will have green borders, otherwise it will have red borders.

     - Version:
     1.0
     */
    func createRoundedRectLayerWithBounds(_ bounds: CGRect, identifier: String) -> CALayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.0])
        shapeLayer.cornerRadius = 7
        shapeLayer.borderWidth = 1

        if identifier.lowercased() == words[0] {
            shapeLayer.borderColor = UIColor.green.cgColor
            if !correctObjectsRecognized[0] {
                showEarnedScore(score: 10)
                correctObjectsRecognized[0] = true
                score += 10
            }

        } else if identifier.lowercased() == words[1] {
            shapeLayer.borderColor = UIColor.green.cgColor
            if !correctObjectsRecognized[1] {
                showEarnedScore(score: 25)
                correctObjectsRecognized[1] = true
                score += 25
            }

        } else if identifier.lowercased() == words[2] {
            shapeLayer.borderColor = UIColor.green.cgColor
            if !correctObjectsRecognized[2] {
                showEarnedScore(score: 50)
                correctObjectsRecognized[2] = true
                score += 50
            }

        } else {
            shapeLayer.borderColor = UIColor.red.cgColor
        }

        return shapeLayer
    }

    /**
     Adds a label showing how much score was earned by finding one of the corrects objects.

     - parameters:
        - score: The score earned by the player when correctly recognizing an object.

     - Version:
     1.0
     */
    func showEarnedScore(score: Int) {
        let scoreEarnedView = ScoreEarnedView()
        view.addSubview(scoreEarnedView)
        scoreEarnedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreEarnedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreEarnedView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            scoreEarnedView.widthAnchor.constraint(equalToConstant: 100),
            scoreEarnedView.heightAnchor.constraint(equalToConstant: 100)
        ])
        scoreEarnedView.show(score: score) {
            scoreEarnedView.removeFromSuperview()
        }
    }
}
