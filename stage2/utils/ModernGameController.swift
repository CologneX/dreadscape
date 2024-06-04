import UIKit
import QuartzCore
import SceneKit
import AVFoundation
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupCamera()
        setupJumpscare()
        setupGestures()
        setUpAudioCapture()
//        playAmbience()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameStateChange(_:)), name: .gameStateDidChange, object: nil)
    }
    
    @objc func handleGameStateChange(_ notification: Notification) {
        if let gameState = notification.object as? String {
            if gameState == "moveObjectToPlayerPosition" {
                moveObjectToPlayerPosition()
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
        safeNode = scene.rootNode.childNode(withName: "Safe reference", recursively: true)!
        shelfNode = scene.rootNode.childNode(withName: "shelf reference", recursively: true)!
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
        let cameraPositionStart = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: cameraNode.position.z)
        
        //Set Camera Light
        cameraNode.light = SCNLight()
        cameraNode.light!.type = .spot
        cameraNode.light?.intensity = 700
        cameraNode.light?.spotInnerAngle = 0
        cameraNode.light?.spotOuterAngle = 120.0
        print(cameraNode.light?.spotOuterAngle.description)
        
        
    }
    
    func setupJumpscare(){
        jumpscareNode.light = SCNLight()
        jumpscareNode.light?.type = .omni
        jumpscareNode.light?.intensity = 0
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
            //            recordingSession.requestRecordPermission({ result in
            //
            //                guard result else { return }
            //            })
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
                if self.db > -12 {
                    
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
        
        let jumpscarePosition = SCNVector3(x: 0.80, y: 2, z: 1)

        
        fallAndFade2("test")
        
        let moveJumpscare = SCNAction.move(to: jumpscarePosition, duration: 0.09)
        playScream()
        moveJumpscare.timingMode = .easeInEaseOut
        jumpscareNode.runAction(moveJumpscare)
        
        let action1 = SCNAction.rotateBy(x: 0, y: -(CGFloat(Float.pi / 8)), z: 0, duration: 0.04)
        let action2 = SCNAction.rotateBy(x: 0, y: (CGFloat(Float.pi / 8)), z: 0, duration: 0.04)

        
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
            }else if (tappedNode.name == "wall"){
                let moveAction = SCNAction.move(to: cameraPositionStart, duration: 1)
                cameraNode.runAction(moveAction)
            }
            
        }
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
    
    func audioTriggered() {

        if(playerLives > 0){
            fallAndFade(cameraNode)
            print(cameraNode.light?.spotOuterAngle)
            playerLives -= 1
        } else {
            playerJumpscare()
        }
        
        let playerPosition = cameraNode.position
        print("ghost: \(ghostNode.position)")
        print("player: \(cameraNode.position)")
        
        moveObjectToPlayerPosition()
        
//        multipeerManager.changeGameState("moveObjectToPlayerPosition")
    }
    
    func openSafeDoor() {
        let rotateAction = SCNAction.rotateTo(x: (90 * .pi / 180), y: (0 * .pi / 180), z: 0, duration: 1.5)
        rotateAction.timingMode = .easeInEaseOut
        self.safeDoorNode.runAction(rotateAction)
    }
    
    func closeSafeDoor() {
        let gearRotationAction = SCNAction.rotateTo(x: 0, y: -(90 * .pi / 180), z: 0, duration: 1)
        let rotateAction = SCNAction.rotateTo(x: (90 * .pi / 180), y: -(90 * .pi / 180), z: 0, duration: 1.5)
        
        rotateAction.timingMode = .easeInEaseOut
        gearRotationAction.timingMode = .easeInEaseOut
        
        self.safeDoorNode.runAction(rotateAction)
    }
    
    @IBAction func fallAndFade(_ sender: Any) {
        SCNTransaction.animationDuration = 1.0
        cameraNode.light?.spotOuterAngle -= 30
    }
    @IBAction func fallAndFade2(_ sender: Any) {
        SCNTransaction.animationDuration = 0.0001
        cameraNode.light?.spotOuterAngle = 120
    }
}
