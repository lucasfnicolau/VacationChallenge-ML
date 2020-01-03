//
//  VisualRecognitionVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 03/01/20.
//  Copyright © 2020 Academy. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class VisionRecognitionVC: RealTimeGameloopVC {

    private var detectionOverlay: CALayer! = nil
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
    }

    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil

        guard let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
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
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))

            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)

            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }

    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let exifOrientation = exifOrientationFromDeviceOrientation()

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }

    override func setupAVCapture() {
        super.setupAVCapture()

        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()

        // start the capture
        startCaptureSession()
    }

    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)

        guard let rootLayer = rootLayer else { return }
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)

        setTopViewElements(on: rootLayer)

        turnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        turnTimer?.fire()
    }

    func setTopViewElements(on layer: CALayer) {

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
    }

    @objc func timerHandler() {
        currentTime -= 1
        self.timerLabel.text = "\(currentTime)"

        if currentTime <= 0 {
            turnTimer?.invalidate()
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func close() {
        // TODO: Notificate
        self.dismiss(animated: true, completion: nil)
    }

    func updateLayerGeometry() {
        guard let rootLayer = rootLayer else { return }
        let bounds = rootLayer.bounds
        var scale: CGFloat

        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width

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

    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }

    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }

}
