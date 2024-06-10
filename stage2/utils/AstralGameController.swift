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
    var jumpscareNode: SCNNode!
    
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
    var colorBallBlue: SCNNode!
    var colorBallYellow: SCNNode!
    var colorBallRed: SCNNode!
    var colorBallGreen: SCNNode!
    var order = -1
    
    //TorchStatus
    var torch1Status = false
    var torch2status = false
    var torch3status = false
    var torch4status = false
    
    //Camera Position
    var cameraPositionStart = SCNVector3(x: 2.315, y: 0.73, z: -0.012)
    
    //Player Lives and State
    var playerLives = 3
    var isJumpscared = false
    
    
    
    
    // Multipeer Connectivity Manager
    var multipeerManager: MultipeerManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupCamera()
        setupPuzzle()
        setupJumpscare()
        setupGestures()
        setUpAudioCapture()
        playAmbience()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameStateChange(_:)), name: .gameStateDidChange, object: nil)
    }
    
    @objc func handleGameStateChange(_ notification: Notification) {
        if let gameState = notification.object as? String {
            if gameState == "moveObjectToPlayerPosition" {
                cameraNode.light?.spotOuterAngle = 40
                playerJumpscare()
                isJumpscared = true
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
        jumpscareNode = scene.rootNode.childNode(withName: "kepalaMonster", recursively: true)!
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
        colorBallBlue = scene.rootNode.childNode(withName: "colorBallBlue", recursively: true)!
        colorBallYellow = scene.rootNode.childNode(withName: "colorBallYellow", recursively: true)!
        colorBallRed = scene.rootNode.childNode(withName: "colorBallRed", recursively: true)!
        colorBallGreen = scene.rootNode.childNode(withName: "colorBallGreen", recursively: true)!
        
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
        _ = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: cameraNode.position.z)
        
        //Set Camera Light
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.light?.intensity = 21.5
        
        cameraNode.light = SCNLight()
        cameraNode.light!.type = .spot
        cameraNode.light?.intensity = 300
        cameraNode.light?.spotInnerAngle = 0
        cameraNode.light?.spotOuterAngle = 60
        cameraNode.light?.color = UIColor.lightGray
        
    }
    
    func playAmbience() {
        let url = Bundle.main.url(forResource: "horror_ambience", withExtension: "mp3")
        player = try! AVAudioPlayer(contentsOf: url!)
        player.volume = 1.0
        player.play()
    }
    
    func setupJumpscare(){
        jumpscareNode.light = SCNLight()
        jumpscareNode.light?.type = .omni
        jumpscareNode.light?.intensity = 0
    }
    
    
    
    func playScream(){
        if let source = SCNAudioSource(fileNamed: "art.scnassets/Audio/scream.mp3") {
            let action = SCNAction.playAudio(source, waitForCompletion: false)
            jumpscareNode.runAction(action)
        } else {
            print("Cannot find the audio file.")
        }
    }
    
    
    
    func playerJumpscare(){
        let moveAction = SCNAction.move(to: cameraPositionStart, duration: 0.2)
        jumpscareNode.light?.intensity = 80
        cameraNode.runAction(moveAction)
        isJumpscared = true
        let jumpscarePosition = SCNVector3(x: 0.80, y: 2, z: 0.8)
//        let jumpscarePosition = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: cameraNode.position.z)
        
        let moveJumpscare = SCNAction.move(to: jumpscarePosition, duration: 0.09)
        moveJumpscare.timingMode = .easeInEaseOut
        
        fallAndFade2("test")
        jumpscareNode.runAction(moveJumpscare)
        playScream()
        
        let action1 = SCNAction.rotateBy(x: 0, y: -(CGFloat(Float.pi / 8)), z: 0, duration: 0.05)
        let action2 = SCNAction.rotateBy(x: 0, y: (CGFloat(Float.pi / 8)), z: 0, duration: 0.05)
        
        jumpscareNode.light?.intensity = 0
        
        jumpscareNode.runAction(SCNAction.repeatForever(SCNAction.sequence([action1,action2])))
        
    }
    
    private func setUpAudioCapture() {
        SCNAction.wait(duration: 10.0)
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
        colorBallBlue.isHidden = true
        colorBallYellow.isHidden = true
        colorBallRed.isHidden = true
        colorBallGreen.isHidden = true
        
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
                
                if self.db > -14 {
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
            rotateCameraRight()
        case .right:
            print("Swiped right")
            rotateCameraLeft()
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
                
            } else if (tappedNode.name == "daun"){
                
                openDoor()
            }
        }
    }
    
    func appendSequence(number: Int, code: Int){
        puzzleSequence[number] = code
        print(puzzleSequence)
        if (puzzleSequence == correctPuzzleSequence){
            
            colorBall1.isHidden = true
            colorBallBlue.isHidden = false
            colorBall2.isHidden = true
            colorBallYellow.isHidden = false
            colorBall3.isHidden = true
            colorBallRed.isHidden = false
            colorBall4.isHidden = true
            colorBallGreen.isHidden = false
            
            
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
        
        if(playerLives > 0){
            print("Chance")
            fallAndFade("test")
            playerLives -= 1
        } else if (playerLives == 0)  {
            if(isJumpscared == false){
                fallAndFade2("test")
                playerJumpscare()
                isJumpscared = true
                multipeerManager.changeGameState("moveObjectToPlayerPosition")
            }
            
        }
        
        _ = cameraNode.position
        print("ghost: \(ghostNode.position)")
        print("player: \(cameraNode.position)")
        
//        moveObjectToPlayerPosition()
        
    }
//    func moveObjectToPlayerPosition() {
//        let position = cameraNode.convertPosition(cameraNode.position, to: scene.rootNode)
//        
//        let positionx = cameraNode.position.x
//        let positiony = cameraNode.position.y - 16
//        let positionz = cameraNode.position.z + 25
//        
//        let position2 = SCNVector3(x: positionx, y: positiony, z: positionz)
//        
//        let moveAction = SCNAction.move(to: position2, duration: 0.05)
//        ghostNode.runAction(moveAction)
//    }
    
    func openDoor() {
        let bola1 = scene.rootNode.childNode(withName: "bola1", recursively: true)!
        let bola2 = scene.rootNode.childNode(withName: "bola2", recursively: true)!
        let bola3 = scene.rootNode.childNode(withName: "bola3", recursively: true)!
        let bola4 = scene.rootNode.childNode(withName: "bola4", recursively: true)!
        let bola5 = scene.rootNode.childNode(withName: "bola5", recursively: true)!
        let centerPintu = scene.rootNode.childNode(withName: "centerPintu", recursively: true)!
        let doorLockNode = scene.rootNode.childNode(withName: "palangPintu", recursively: true)!
        let leftDoorNode = scene.rootNode.childNode(withName: "pintuKiri", recursively: true)!
        let rightDoorNode = scene.rootNode.childNode(withName: "pintuKanan", recursively: true)!
//        let backgroundPintu = scene.rootNode.childNode(withName: "backgroundPintu", recursively: true)!

        let bolaFadeOutAnimation: SCNAction = SCNAction.run { _ in
            bola1.runAction(SCNAction.fadeOut(duration: 1.5))
            bola2.runAction(SCNAction.fadeOut(duration: 1.5))
            bola3.runAction(SCNAction.fadeOut(duration: 1.5))
            bola4.runAction(SCNAction.fadeOut(duration: 1.5))
            bola5.runAction(SCNAction.fadeOut(duration: 1.5))
            centerPintu.runAction(SCNAction.fadeOut(duration: 1.5))
        }
        let doorLockAnimation:SCNAction = SCNAction.run { _ in
            doorLockNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: 0.5, duration: 1.5))
        }
        let doorLockOpacityAnimation: SCNAction = SCNAction.run { _ in
            doorLockNode.runAction(SCNAction.fadeOut(duration: 1.5))
        }
        
        // Set area light intensity to 5000 in the duration of 1 second
//        let backgroundPintuIntensity = SCNAction.run { _ in
//            backgroundPintu.light?.intensity = 5000
//        }
//        backgroundPintuIntensity.timingMode = .easeIn
//        backgroundPintuIntensity.duration = 3
        
        
        let leftDoorAnimation = SCNAction.run { _ in
            leftDoorNode.runAction(SCNAction.rotateTo(x: 0, y: 1.8, z: 0, duration: 1.5))
        }
        leftDoorAnimation.timingMode = .easeInEaseOut
        
        
        let rightDoorAnimation = SCNAction.run { _ in
            rightDoorNode.runAction(SCNAction.rotateTo(x: 0, y: -1.8, z: 0, duration: 1.5))
        }
        rightDoorAnimation.timingMode = .easeInEaseOut
        
        // Sequence animation
        let sequence = SCNAction.sequence([
//            backgroundPintuIntensity,
            bolaFadeOutAnimation,
            SCNAction.wait(duration: 1.5),
            doorLockAnimation,
            SCNAction.wait(duration: 1),
            doorLockOpacityAnimation,
            SCNAction.wait(duration: 1.5),
            leftDoorAnimation, rightDoorAnimation])
        self.scene.rootNode.runAction(sequence)
        
        
    }
    
    @IBAction func fallAndFade(_ sender: Any) {
        SCNTransaction.animationDuration = 1.0
        cameraNode.light?.spotOuterAngle -= 7
    }
    @IBAction func fallAndFade2(_ sender: Any) {
        SCNTransaction.animationDuration = 0.001
        cameraNode.light?.spotOuterAngle = 40
    }
}

#Preview(){
    AstralGameController()
}
