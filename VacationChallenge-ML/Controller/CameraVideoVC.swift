//
//  CameraVideoVC.swift
//  VacationChallenge-ML
//
//  Created by Lucas Fernandez Nicolau on 03/01/20.
//  Copyright © 2020 Academy. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameHandlerDelegate: GameStateDelegate {
    func startGame(numOfPlayers: Int)
    func beginTurn(for words: [String], andCurrentPlayer player: Int)
    func endTurn(withScore score: Int)
    func showWinner(player: Int)
}

protocol GameStateDelegate {
    func changeGameState(to gameState: GameState)
}

class CameraVideoVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var visionRecognitionVC: VisionRecognitionVC?
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer?
    var gameState: GameState = .mainMenu
    var viewControllers = [ViewController: UIViewController]()
    var words: [String] = []
    var currentPlayer = 0
    var numOfPlayers = 2
    var score = 0
    var winner = 0

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

        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ViewController.visionRecognition.rawValue) as? VisionRecognitionVC {

            visionRecognitionVC = vc
            visionRecognitionVC?.gameHandlerDelegate = self
            visionRecognitionVC?.cameraVideoVC = self
            viewControllers[.visionRecognition] = visionRecognitionVC

            DispatchQueue(label: "Vision", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: .main).async {
                self.visionRecognitionVC?.setupAVCapture()
            }
        }
    }

    /**
     Instantiate the MainMenuVC to start a new game.

     - Version:
     1.0
     */
    func initiateGame() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainMenuVC = storyboard.instantiateViewController(withIdentifier: ViewController.mainMenu.rawValue) as? MainMenuVC {
            mainMenuVC.gameHandlerDelegate = self
            viewControllers[.mainMenu] = mainMenuVC
            self.add(mainMenuVC)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        if gameState == .visualRecognition {
            visionRecognitionVC?.captureOutput(output, didOutput: sampleBuffer, from: connection)
        }
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

extension CameraVideoVC: GameHandlerDelegate, GameStateDelegate {

    /**
     Starts a new game with the given number of players.

     - parameters:
        - numOfPlayer: The number of players that will play the game.

     - Version:
     1.0
     */
    func startGame(numOfPlayers: Int) {
        self.numOfPlayers = numOfPlayers
        changeGameState(to: .gameloop)
    }

    /**
     Begins a new turn by getting the words of the current turn and the current player. This functions also calls 'changeGameState(to: .visualRecognition)'.

     - parameters:
        - words: The words that will be used in the current turn.
        - player: The current player.

     - Version:
     1.0
     */
    func beginTurn(for words: [String], andCurrentPlayer player: Int) {
        self.words = words
        self.currentPlayer = player
        changeGameState(to: .visualRecognition)
    }

    /**
     Ends the current turn and update the score earned in it.

     - parameters:
         - score: The score achieved by the player.

     - Version:
     1.0
     */
    func endTurn(withScore score: Int) {
        self.score = score
        changeGameState(to: .endTurn)
    }

    /**
     Ends the match and shows the winner player.

     - parameters:
        - player: The player that won the match.

     - Version:
     1.0
     */
    func showWinner(player: Int) {
        winner = player
        changeGameState(to: .showWinner)
    }

    /**
     Changes the Game State to the one desired.

     - parameters:
        - gameState: The game state to be transitioned to.

     - Version:
     1.0
     */
    func changeGameState(to gameState: GameState) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.gameState = gameState

        switch gameState {
        case .mainMenu:
            viewControllers.values.forEach { (vc) in
                vc.remove()
            }
            if let mainMenuVC = viewControllers[.mainMenu] {
                mainMenuVC.view.isHidden = false
                self.add(mainMenuVC)
            }

        case .gameloop:
            viewControllers[.mainMenu]?.view.isHidden = true
            if let gameloopVC = storyboard.instantiateViewController(withIdentifier: ViewController.gameloop.rawValue) as? GameloopVC {
                gameloopVC.gameHandlerDelegate = self
                gameloopVC.playersNumber = numOfPlayers
                viewControllers[.gameloop] = gameloopVC
                self.add(gameloopVC)
            }

        case .ranking:
            viewControllers[.mainMenu]?.view.isHidden = true
            if let rankingVC = storyboard.instantiateViewController(withIdentifier: ViewController.ranking.rawValue) as? RankingVC {
                rankingVC.gameHandlerDelegate = self
                viewControllers[.ranking] = rankingVC
                self.add(rankingVC)
            }

        case .visualRecognition:
            viewControllers[.gameloop]?.view.isHidden = true
            if let visionRecognitionVC = viewControllers[.visionRecognition] as? VisionRecognitionVC {
                visionRecognitionVC.view.isHidden = false
                visionRecognitionVC.words = self.words
                visionRecognitionVC.currentPlayer = self.currentPlayer
                visionRecognitionVC.startTurn()
                visionRecognitionVC.gameHandlerDelegate = self
                self.add(visionRecognitionVC)
            }

        case .endTurn:
            viewControllers[.visionRecognition]?.view.isHidden = true
            if let gameloopVC = viewControllers[.gameloop] as? GameloopVC {
                gameloopVC.view.isHidden = false
                gameloopVC.players[currentPlayer].addScore(score)
                score = 0
                gameloopVC.setNewTurn()
            }

            case .showWinner:
                currentPlayer = 0
                numOfPlayers = 2
                score = 0
                viewControllers.values.forEach { (vc) in
                    vc.view.isHidden = true
                }
                if let winnerVC = storyboard.instantiateViewController(withIdentifier: ViewController.winner.rawValue) as? WinnerVC {
                    winnerVC.gameHandlerDelegate = self
                    winnerVC.player = winner
                    viewControllers[.winner] = winnerVC
                    self.add(winnerVC)
            }
        }
    }
}
