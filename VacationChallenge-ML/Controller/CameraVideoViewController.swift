//
//  CameraVideoViewController.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 03/01/20.
//  Copyright © 2020 Academy. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameHandlerDelegate {
    func startGame(numOfPlayers: Int)
}

protocol GameStateDelegate {
    func changeGameState(to gameState: GameState)
}

class CameraVideoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var bufferSize: CGSize = .zero
    var rootLayer: CALayer?
    var gameState: GameState = .mainMenu
    var viewControllers = [ViewController: UIViewController]()

    @IBOutlet weak private var previewView: UIView!
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()

    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        startCaptureSession()
        initiateGame()
    }

    func initiateGame() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainMenuVC = storyboard.instantiateViewController(withIdentifier: ViewController.mainMenu.rawValue) as? MainMenuVC {
            mainMenuVC.gameHandlerDelegate = self
            viewControllers[.mainMenu] = mainMenuVC
            self.add(mainMenuVC)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }

    /**
     Configure the AV Capture Device by setting its proprieties like mediaType and what camera will be used. This function also sets the video resolution of the camera and the camera layer.

     - Version:
     1.0
     */
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput?

        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            guard let videoDevice = videoDevice else { return }
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.

        guard let deviceInputUnwrapped = deviceInput else { return }

        // Add a video input
        guard session.canAddInput(deviceInputUnwrapped) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInputUnwrapped)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        guard let rootLayer = rootLayer else { return }
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }

    /**
     Starts the capture session.

     - Version:
     1.0
     */
    func startCaptureSession() {
        session.startRunning()
    }

    /**
     Clean up the capture setup.

     - Version:
     1.0
     */
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }

//    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        // print("frame dropped")
//    }

    /**
     Handles the image orientation.

     - Version:
     1.0
     */
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation

        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}

extension CameraVideoViewController: GameHandlerDelegate, GameStateDelegate {
    func startGame(numOfPlayers: Int) {
        // TODO
        changeGameState(to: .gameloop)
    }

    func changeGameState(to gameState: GameState) {

        switch gameState {
        case .mainMenu:
            // TODO
            break
        case .gameloop:
            viewControllers[.mainMenu]?.view.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let gameloopVC = storyboard.instantiateViewController(withIdentifier: ViewController.gameloop.rawValue) as? GameloopVC {
                viewControllers[.gameloop] = gameloopVC
                self.add(gameloopVC)
            }
            break
        }
    }
}
