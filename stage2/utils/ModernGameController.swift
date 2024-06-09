import UIKit
import QuartzCore
import SceneKit
import AVFoundation
import SpriteKit
class ModernGameController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    // Nodes
    var cameraNode: SCNNode!
    var ghostNode: SCNNode!
    var roomNode: SCNNode!
    var lightNode: SCNNode!
    var bassNode: SCNNode!
    var safeNode: SCNNode!
    var safeDoorNode: SCNNode!
    var shelfNode: SCNNode!
    var jumpscareNode: SCNNode!
    var indicatorSafe: SCNNode!
    var doorNode: SCNNode!
    
    //Safe Puzzles Node
    var symbol1Slot: SCNNode!
    var symbol2Slot: SCNNode!
    var symbol3Slot: SCNNode!
    var symbol4Slot: SCNNode!
    var symbol1: SCNNode!
    
    var symbol1Indicator: SCNNode!
    var symbol2Indicator: SCNNode!
    var symbol3Indicator: SCNNode!
    var symbol4Indicator: SCNNode!
    
    var symbolSlots: [SCNNode]!
    
    var selectedSlot: SCNNode!
    //Puzzles
    var puzzleScreen = SCNScene()
    var puzzleSequence: [Int] = [0,0,0,0]
    var correctPuzzleSequence: [Int] = [1,7,4,2]
    var puzzleCount = 0
    var selectedSlotNumber = 0
    
    var material2 = SCNMaterial()
    
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
    
    //Camera Position
    var cameraPositionStart = SCNVector3(x: -3.801, y: 137.466, z: 103.739)
    
    // Multipeer Connectivity Manager
    var multipeerManager: MultipeerManager!
    
    //Player Lives and State
    var playerLives = 3
    var isJumpscared = false
    
    //Safe
    var isOpen = false
    
    //Images Symbol
    var image1: UIImage!
    var image2: UIImage!
    var image3: UIImage!
    var image4: UIImage!
    var image5: UIImage!
    var image6: UIImage!
    var image7: UIImage!
    var image8: UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupCamera()
        setupPuzzle()
        puzzleView()
        setupJumpscare()
        setupGestures()
        setUpAudioCapture()
        //        playAmbience()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameStateChange(_:)), name: .gameStateDidChange, object: nil)
    }
    
    @objc func handleGameStateChange(_ notification: Notification) {
        if let gameState = notification.object as? String {
            print(gameState)
            if gameState == "moveObjectToPlayerPosition" {
//                moveObjectToPlayerPosition()
                cameraNode.light?.spotOuterAngle = 80
                playerJumpscare()
                isJumpscared = true
            }
        }
    }
    
    //SETUP SCENE
    func setupNode() {
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        ghostNode = scene.rootNode.childNode(withName: "wayangMonster reference", recursively: false)!
        roomNode = scene.rootNode.childNode(withName: "Room2 reference", recursively: true)!
        bassNode = scene.rootNode.childNode(withName: "bass reference", recursively: false)
        lightNode = scene.rootNode.childNode(withName: "omni", recursively: true)!
        jumpscareNode = scene.rootNode.childNode(withName: "kepalaMonster", recursively: true)!
        safeNode = scene.rootNode.childNode(withName: "safe reference", recursively: true)!
        safeDoorNode = scene.rootNode.childNode(withName: "Hinge", recursively: true)!
        shelfNode = scene.rootNode.childNode(withName: "shelf reference", recursively: true)!
        indicatorSafe = scene.rootNode.childNode(withName: "indicatorSafe", recursively: true)
        doorNode = roomNode.childNode(withName: "door", recursively: false)!
        
        //Puzzle Node
        symbol1Slot = scene.rootNode.childNode(withName: "symbol1Slot", recursively: true)!
        symbol2Slot = scene.rootNode.childNode(withName: "symbol2Slot", recursively: true)!
        symbol3Slot = scene.rootNode.childNode(withName: "symbol3Slot", recursively: true)!
        symbol4Slot = scene.rootNode.childNode(withName: "symbol4Slot", recursively: true)!
        
        symbol1Indicator = scene.rootNode.childNode(withName: "slotSelected1", recursively: true)!
        symbol2Indicator = scene.rootNode.childNode(withName: "slotSelected2", recursively: true)!
        symbol3Indicator = scene.rootNode.childNode(withName: "slotSelected3", recursively: true)!
        symbol4Indicator = scene.rootNode.childNode(withName: "slotSelected4", recursively: true)!
        
        symbol1 = scene.rootNode.childNode(withName: "symbol1", recursively: true)
    }
    
    func setupScene() {
        scene = SCNScene(named: "art.scnassets/mainScene.scn")
        sceneView = SCNView(frame: self.view.bounds)
        sceneView.allowsCameraControl = false
        
        sceneView.scene = scene
        
        
        // Add the SCNView to the view controller's view
        self.view.addSubview(sceneView)
        
        
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        
        tapRecognizer.addTarget(self, action: #selector(ModernGameController.sceneViewTapped(recognizer:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupCamera() {
        //Camera Position Start
        _ = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: cameraNode.position.z)
        
        //Set Camera Light
        cameraNode.light = SCNLight()
        cameraNode.light!.type = .spot
        cameraNode.light?.intensity = 700
        cameraNode.light?.spotInnerAngle = 0
        cameraNode.light?.spotOuterAngle = 120.0
        
        
    }
    
    func setupJumpscare(){
        jumpscareNode.light = SCNLight()
        jumpscareNode.light?.type = .omni
        jumpscareNode.light?.intensity = 0
    }
    
    func setupPuzzle(){
        image1 = UIImage(named: "symbol1.png")
        image2 = UIImage(named: "symbol2.png")
        image3 = UIImage(named: "symbol3.png")
        image4 = UIImage(named: "symbol4.png")
        image5 = UIImage(named: "symbol5.png")
        image6 = UIImage(named: "symbol6.png")
        image7 = UIImage(named: "symbol7.png")
        image8 = UIImage(named: "symbol8.png")
        
        symbol1Indicator.isHidden = true
        symbol2Indicator.isHidden = true
        symbol3Indicator.isHidden = true
        symbol4Indicator.isHidden = true
    }
    
    func playAmbience() {
        let url = Bundle.main.url(forResource: "horror_ambience", withExtension: "mp3")
        player = try! AVAudioPlayer(contentsOf: url!)
        player.volume = 1.0
        player.play()
    }
    
    func playStep() {
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
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                audioRecorder.updateMeters()
                self.db = audioRecorder.averagePower(forChannel: 0)
                print(self.db)
                if self.db > -14 {
                    self.audioTriggered()
                    print("Triggered")
                }
            }
        } catch {
            print("ERROR: Failed to start recording process.")
        }
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
        cameraNode.runAction(moveAction)
        isJumpscared = true
        let jumpscarePosition = SCNVector3(x: 0.80, y: 2, z: 0.8)
//        let jumpscarePosition = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: cameraNode.position.z)
        
        SCNAction.wait(duration: 3)
        let moveJumpscare = SCNAction.move(to: jumpscarePosition, duration: 0.09)
        moveJumpscare.timingMode = .easeInEaseOut
        
        fallAndFade2("test")
        jumpscareNode.runAction(moveJumpscare)
        playScream()
        
        let action1 = SCNAction.rotateBy(x: 0, y: -(CGFloat(Float.pi / 8)), z: 0, duration: 0.05)
        let action2 = SCNAction.rotateBy(x: 0, y: (CGFloat(Float.pi / 8)), z: 0, duration: 0.05)
        
        
        jumpscareNode.runAction(SCNAction.repeatForever(SCNAction.sequence([action1,action2])))
        
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
    
    //Tap Screen Mechanism
    @objc func sceneViewTapped(recognizer: UITapGestureRecognizer) {
        
        
        let p = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if let hitResult = hitResults.first {
            let tappedNode = hitResult.node
            print("node tapped: \(tappedNode)")
            
            
            //Check What Tapped
            if(tappedNode.name == "bass1" || tappedNode.name == "bass2"){
                let bassPositionX = bassNode.position.x
                let bassPositionY = bassNode.position.y
                let bassPositionZ = bassNode.position.z + 150
                
                let positionTo = SCNVector3(x: bassPositionX, y: bassPositionY, z: bassPositionZ)
                let moveAction = SCNAction.move(to: positionTo, duration: 1)
                cameraNode.runAction(moveAction)
            } else if(tappedNode.name == "stool1" || tappedNode.name == "stool2" || tappedNode.name == "safe"){
                let safePositionX = safeNode.position.x
                let safePositionY = safeNode.position.y
                let safePositionZ = safeNode.position.z + 150
                
                let positionTo = SCNVector3(x: safePositionX, y: safePositionY, z: safePositionZ)
                let moveAction = SCNAction.move(to: positionTo, duration: 1)
                cameraNode.runAction(moveAction)
            }
            else if(tappedNode.name == "shelf"){
                let shelfPositionX = shelfNode.position.x - 55
                let shelfPositionY = shelfNode.position.y + 134
                let shelfPositionZ = shelfNode.position.z + 234
                
                let positionTo = SCNVector3(x: shelfPositionX, y: shelfPositionY, z: shelfPositionZ)
                let moveAction = SCNAction.move(to: positionTo, duration: 1)
                cameraNode.runAction(moveAction)
            }
            else if (tappedNode.name == "wall"){
                let moveAction = SCNAction.move(to: cameraPositionStart, duration: 1)
                cameraNode.runAction(moveAction)
            } else if (tappedNode.name == "door"){
                openDoor()
            }
            
            
            let material = SCNMaterial()
            let material3 = SCNMaterial()
            let material4 = SCNMaterial()
            let material5 = SCNMaterial()
            let material6 = SCNMaterial()
            let material7 = SCNMaterial()
            let material8 = SCNMaterial()
            let material9 = SCNMaterial()
            
            
            if(tappedNode.name == "symbol1Slot"){
                selectedSlot = symbol1Slot
                selectedSlotNumber = 0
                
                symbol1Indicator.isHidden = false
                symbol2Indicator.isHidden = true
                symbol3Indicator.isHidden = true
                symbol4Indicator.isHidden = true
                
            } else if (tappedNode.name == "symbol2Slot"){
                selectedSlot = symbol2Slot
                selectedSlotNumber = 1
                
                symbol1Indicator.isHidden = true
                symbol2Indicator.isHidden = false
                symbol3Indicator.isHidden = true
                symbol4Indicator.isHidden = true
            } else if (tappedNode.name == "symbol3Slot"){
                selectedSlot = symbol3Slot
                selectedSlotNumber = 2
                
                symbol1Indicator.isHidden = true
                symbol2Indicator.isHidden = true
                symbol3Indicator.isHidden = false
                symbol4Indicator.isHidden = true
            } else if (tappedNode.name == "symbol4Slot"){
                selectedSlot = symbol4Slot
                selectedSlotNumber = 3
                
                symbol1Indicator.isHidden = true
                symbol2Indicator.isHidden = true
                symbol3Indicator.isHidden = true
                symbol4Indicator.isHidden = false
            }
            
            
            if(selectedSlot != nil){
                
                if(tappedNode.name == "symbol1"){
                    appendSymbol(number:selectedSlotNumber, code: 1)
                    
                    material.diffuse.contents = image1
                    selectedSlot.geometry?.materials = [material]
                } else if(tappedNode.name == "symbol2"){
                    appendSymbol(number:selectedSlotNumber, code: 2)
                    
                    material3.diffuse.contents = image2
                    selectedSlot.geometry?.materials = [material3]
                }else if(tappedNode.name == "symbol3"){
                    appendSymbol(number:selectedSlotNumber, code: 3)
                    
                    material4.diffuse.contents = image3
                    selectedSlot.geometry?.materials = [material4]
                }else if(tappedNode.name == "symbol4"){
                    appendSymbol(number:selectedSlotNumber, code: 4)
                    
                    material5.diffuse.contents = image4
                    selectedSlot.geometry?.materials = [material5]
                }else if(tappedNode.name == "symbol5"){
                    appendSymbol(number:selectedSlotNumber, code: 5)
                    
                    material6.diffuse.contents = image5
                    selectedSlot.geometry?.materials = [material6]
                }else if(tappedNode.name == "symbol6"){
                    appendSymbol(number:selectedSlotNumber, code: 6)
                    
                    material7.diffuse.contents = image6
                    selectedSlot.geometry?.materials = [material7]
                }else if(tappedNode.name == "symbol7"){
                    appendSymbol(number:selectedSlotNumber, code: 7)
                    
                    material8.diffuse.contents = image7
                    selectedSlot.geometry?.materials = [material8]
                }else if(tappedNode.name == "symbol8"){
                    appendSymbol(number:selectedSlotNumber, code: 8)
                    
                    material9.diffuse.contents = image8
                    selectedSlot.geometry?.materials = [material9]
                }
            } else {
                print("No Selected Slot")
            }
            
            
        }
    }
    
    func appendSymbol(number: Int, code: Int){
        puzzleSequence[number] = code
        if(puzzleSequence == correctPuzzleSequence) {
            print("CORRECT")
            material2.diffuse.contents = UIColor.green
            indicatorSafe.geometry?.materials = [material2]
            openSafeDoor()
        }
        
        print(puzzleSequence)
        
    }
    
    
//    func moveObjectToPlayerPosition() {
//        _ = cameraNode.convertPosition(cameraNode.position, to: scene.rootNode)
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
    
    func openSafeDoor() {
        let rotateAction = SCNAction.rotateTo(x: (90 * .pi / 180), y: (0 * .pi / 180), z: 0, duration: 1.5)
        rotateAction.timingMode = .easeInEaseOut
        self.safeDoorNode.runAction(rotateAction)
    }
    
    func closeSafeDoor() {
        let rotateAction = SCNAction.rotateTo(x: (90 * .pi / 180), y: -(90 * .pi / 180), z: 0, duration: 1.5)
        
        rotateAction.timingMode = .easeInEaseOut
        
        self.safeDoorNode.runAction(rotateAction)
    }
    
    func openDoor() {
        let rotateAction = SCNAction.rotateTo(x: 0, y: -(90 * .pi / 180), z: 0, duration: 1.5)
        rotateAction.timingMode = .easeInEaseOut
        self.doorNode.runAction(rotateAction)
    }
    //Puzzle Mechanism
    func puzzleView(){
        
        
    }
    
    
    @IBAction func fallAndFade(_ sender: Any) {
        SCNTransaction.animationDuration = 1.0
        cameraNode.light?.spotOuterAngle -= 30
    }
    @IBAction func fallAndFade2(_ sender: Any) {
        SCNTransaction.animationDuration = 0.001
        cameraNode.light?.spotOuterAngle = 80
    }
    
    
    
}

