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
    private var detectionOverlay: CALayer! = nil
    var gameHandlerDelegate: GameHandlerDelegate?
    var currentPlayer = 0
    var currentTime = 60
    var turnTimer: Timer?
    var timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "60"
        label.font = UIFont(name: Font.norwester.rawValue, size: 28)
        return label
    }()
    var closeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "multiply.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        return button
    }()

    // Vision parts
    private var requests = [VNRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
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
        - results: An array containing all results given by the model. Can not be empty.

     - Version:
     1.0
     */
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(cameraVideoVC.bufferSize.width), Int(cameraVideoVC.bufferSize.height))

            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)

            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
//            let textBoxLayer = CAShapeLayer()
//            textBoxLayer.bounds = textLayer.bounds
//            textBoxLayer.position = textLayer.position
//            textBoxLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 1.0, 0.0, 1.0])
//            textBoxLayer.addSublayer(textLayer)

            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }

    /*override*/ func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

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

    /*override*/ func setupAVCapture() {
//        super.setupAVCapture()

        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()

        // start the capture
//        startCaptureSession()
    }

    /**
     Configure the layers that will be used to show all the renderings of the observations.

     - Version:
     1.0
     */
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: cameraVideoVC.bufferSize.width,
                                         height: cameraVideoVC.bufferSize.height)

        guard let rootLayer = cameraVideoVC.rootLayer else { return }
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)

        setTopViewElements()
    }

    /**
     Create the elements that will be displayet at the top of the view. These elements are the current player image view, the timer label and the close button. This function also fires the turn timer after it creation.

     - Version:
     1.0
     */
    func setTopViewElements() {

        let playerImageView = UIImageView(image: UIImage(named: "\(currentPlayer)"))
        guard let image = playerImageView.image else { return }
        let size = (image.size.width, image.size.height)

        self.view.addSubview(playerImageView)
        self.view.addSubview(timerLabel)
        self.view.addSubview(closeButton)

        playerImageView.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            playerImageView.topAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.topAnchor, constant: 4),
            playerImageView.widthAnchor.constraint(equalToConstant: size.0 * 0.95),
            playerImageView.heightAnchor.constraint(equalToConstant: size.1 * 0.95),

            timerLabel.centerYAnchor.constraint(equalTo: playerImageView.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 45),
            closeButton.heightAnchor.constraint(equalToConstant: 45)
        ])

        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        turnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        turnTimer?.fire()
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
            dismiss(animated: true, completion: nil)
        }
    }

    /**
     Dismiss this view controller.

     - Version:
     1.0
     */
    @objc func close() {
        // TODO: Notificate
        self.dismiss(animated: true, completion: nil)
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
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)

        CATransaction.commit()

    }

    /**
     Create the text layer to fit in the bounds of the image recognized with all the customizations of the text.

     - Version:
     1.0
     */
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: Font.norwester.rawValue, size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }

    /**
     Create a rounded rectangle with colored borders to highlight the recognized object.

     - Version:
     1.0
     */
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.0])
        shapeLayer.cornerRadius = 7
        shapeLayer.borderWidth = 1
        shapeLayer.borderColor = UIColor.green.cgColor

        return shapeLayer
    }

}
