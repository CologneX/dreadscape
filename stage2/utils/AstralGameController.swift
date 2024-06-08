//
//  AstralGameController.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 03/06/24.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class AstralGameController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    // Nodes
    var cameraNode: SCNNode!
    var ghostNode: SCNNode!
    var isekaiRoomNode: SCNNode!
    var lightNode: SCNNode!
    var pillarPertamaNode: SCNNode!
    var pillarKeduaNode: SCNNode!
    var pillarKetigaNode: SCNNode!
    var pillarKeempatNode: SCNNode!
    var torch1: SCNNode!
    var torch2: SCNNode!
    var torch3: SCNNode!
    var torch4: SCNNode!
    var light1: SCNNode!
    var light2: SCNNode!
    var light3: SCNNode!
    var light4: SCNNode!
    
    // Safe Nodes
    var safeNode: SCNNode!
    var safeDoorNode: SCNNode!
    
    // Position
    var isDone = false
    var isMoved = false
    
    // Sounds
    var db: Float!
    var sounds: [String: SCNAudioSource] = [:]
    var player: AVAudioPlayer!
    
    //Limit
    var isLeft = 1
    var isRight = 1
    
    //PillarPuzzle
    var correctPuzzleSequence: [Int] = [1,3,2,4]
    var puzzleSequence: [Int] = [0,0,0,0]
    var colorBall1: SCNNode!
    var colorBall2: SCNNode!
    var colorBall3: SCNNode!
    var colorBall4: SCNNode!
    var order = -1
    
    //TorchStatus
    var torch1Status = false
    var torch2status = false
    var torch3status = false
    var torch4status = false
    
    
    
    
    // Multipeer Connectivity Manager
    var multipeerManager: MultipeerManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupCamera()
        setupPuzzle()
        setupGestures()
        setUpAudioCapture()
        playAmbience()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameStateChange(_:)), name: .gameStateDidChange, object: nil)
    }
    
    @objc func handleGameStateChange(_ notification: Notification) {
        if let gameState = notification.object as? String {
            if gameState == "moveObjectToPlayerPosition" {
                moveObjectToPlayerPosition()
            }
        }
    }
    @objc func handleUserDidDisconnect() {
        // Navigate back to main menu
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //SETUP SCENE
    func setupNode() {
        cameraNode = scene.rootNode.childNode(withName: "Camera", recursively: true)!
        ghostNode = scene.rootNode.childNode(withName: "wayangMonster reference", recursively: false)!
        lightNode = scene.rootNode.childNode(withName: "Light", recursively: true)!
        pillarPertamaNode = scene.rootNode.childNode(withName: "pillarPertama", recursively: true)!
        pillarKeduaNode = scene.rootNode.childNode(withName: "pillarKedua", recursively: true)!
        pillarKetigaNode = scene.rootNode.childNode(withName: "pillarKetiga", recursively: true)!
        pillarKeempatNode = scene.rootNode.childNode(withName: "pillarKeempat", recursively: true)!
        torch1 = scene.rootNode.childNode(withName: "torch1", recursively: false)!
        torch2 = scene.rootNode.childNode(withName: "torch2", recursively: false)!
        torch3 = scene.rootNode.childNode(withName: "torch3", recursively: false)!
        torch4 = scene.rootNode.childNode(withName: "torch4", recursively: false)!
        light1 = scene.rootNode.childNode(withName: "light1", recursively: true)!
        light2 = scene.rootNode.childNode(withName: "light2", recursively: true)!
        light3 = scene.rootNode.childNode(withName: "light3", recursively: true)!
        light4 = scene.rootNode.childNode(withName: "light4", recursively: true)!
        colorBall1 = scene.rootNode.childNode(withName: "torch1Color", recursively: true)!
        colorBall2 = scene.rootNode.childNode(withName: "torch2Color", recursively: true)!
        colorBall3 = scene.rootNode.childNode(withName: "torch3Color", recursively: true)!
        colorBall4 = scene.rootNode.childNode(withName: "torch4Color", recursively: true)!
        
        
    }
    
    func setupScene() {
        scene = SCNScene(named: "art.scnassets/isekaiScene.scn")
        sceneView = SCNView(frame: self.view.bounds)
        sceneView.allowsCameraControl = false
        
        sceneView.scene = scene
        
        // Add the SCNView to the view controller's view
        self.view.addSubview(sceneView)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        
        tapRecognizer.addTarget(self, action: #selector(AstralGameController.sceneViewTapped(recognizer:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupCamera() {
        //Camera Position Start
        let cameraPositionStart = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: cameraNode.position.z)
        
    }
    
    func playAmbience() {
        let url = Bundle.main.url(forResource: "horror_ambience", withExtension: "mp3")
        player = try! AVAudioPlayer(contentsOf: url!)
        player.volume = 1.0
        player.play()
    }
    
    private func setUpAudioCapture() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord)
            try recordingSession.setActive(true)
            AVAudioApplication.requestRecordPermission(completionHandler: {
                response in print(response)
            })
            captureAudio()
        } catch {
            print("Error: Failed to set up recording session.")
        }
    }
    
    func setupPuzzle(){
        light1.isHidden = true
        light2.isHidden = true
        light3.isHidden = true
        light4.isHidden = true
    }
    
    private func captureAudio() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                audioRecorder.updateMeters()
                self.db = audioRecorder.averagePower(forChannel: 0)
                
                if self.db > -5 {
                    self.audioTriggered()
                    print("Triggered")
                }
                print(self.db!)
            }
        } catch {
            print("ERROR: Failed to start recording process.")
        }
    }
    
    @objc func rotateCameraLeft() {
        
        //Check if next move is at limit or not
        if(isLeft != 2){
            let rotateAction = SCNAction.rotateBy(x: 0, y: -(CGFloat(Float.pi / 2)), z: 0, duration: 1.0)
            print(cameraNode.eulerAngles)
            
            // Run the rotation action
            cameraNode.runAction(rotateAction)
            isLeft += 1
            isRight -= 1
        }
        
        // Define the rotation action
        
    }
    
    @objc func rotateCameraRight() {
        
        if(isRight != 2){
            // Define the rotation action
            let rotateAction = SCNAction.rotateBy(x: 0, y: (CGFloat(Float.pi / 2)), z: 0, duration: 1.0)
            
            // Run the rotation action
            cameraNode.runAction(rotateAction)
            isRight += 1
            isLeft -= 1
        }
    }
    
    func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            print("Swiped left")
            rotateCameraLeft()
        case .right:
            print("Swiped right")
            rotateCameraRight()
        default:
            break
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    @objc func sceneViewTapped(recognizer: UITapGestureRecognizer) {
        let p = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if let hitResult = hitResults.first {
            let tappedNode = hitResult.node
            print("node tapped: \(tappedNode)")
            if(tappedNode.name == "torch1"){
                if(light1.isHidden == true){
                    order += 1
                }
                light1.isHidden = false
                
                appendSequence(number: order, code: 1)
                
            } else if (tappedNode.name == "torch2"){
                if(light2.isHidden == true){
                    order += 1
                }
                light2.isHidden = false
                
                appendSequence(number: order, code: 2)
                
            }else if (tappedNode.name == "torch3"){
                if(light3.isHidden == true){
                    order += 1
                }
                light3.isHidden = false
                
                appendSequence(number: order, code: 3)
                
            }else if (tappedNode.name == "torch4"){
                if(light4.isHidden == true){
                    order += 1
                }
                light4.isHidden = false
                
                appendSequence(number: order, code: 4)
                
            }
        }
    }
    
    func appendSequence(number: Int, code: Int){
        puzzleSequence[number] = code
        print(puzzleSequence)
        if (puzzleSequence == correctPuzzleSequence){
            
            let material1 = SCNMaterial()
            let material2 = SCNMaterial()
            let material3 = SCNMaterial()
            let material4 = SCNMaterial()
            
            material1.diffuse.contents = UIColor.red
            material2.diffuse.contents = UIColor.blue
            material3.diffuse.contents = UIColor.green
            material4.diffuse.contents = UIColor.yellow
            
            colorBall3.geometry?.materials = [material1]
            colorBall1.geometry?.materials = [material2]
            colorBall4.geometry?.materials = [material3]
            colorBall2.geometry?.materials = [material4]
            
            
        } else if (puzzleSequence[0] != 0 && puzzleSequence[1] != 0 && puzzleSequence[2] != 0 && puzzleSequence[3] != 0) {
            puzzleSequence[0] = 0
            puzzleSequence[1] = 0
            puzzleSequence[2] = 0
            puzzleSequence[3] = 0
            
            light1.isHidden = true
            light2.isHidden = true
            light3.isHidden = true
            light4.isHidden = true
            
            order = 0
        }
    }
    
    func audioTriggered() {
        moveObjectToPlayerPosition()
        multipeerManager.changeGameState("moveObjectToPlayerPosition")
    }
    func moveObjectToPlayerPosition() {
        let position = cameraNode.convertPosition(cameraNode.position, to: scene.rootNode)
        
        let positionx = cameraNode.position.x
        let positiony = cameraNode.position.y - 16
        let positionz = cameraNode.position.z + 25
        
        let position2 = SCNVector3(x: positionx, y: positiony, z: positionz)
        
        let moveAction = SCNAction.move(to: position2, duration: 0.05)
        ghostNode.runAction(moveAction)
    }
}
