import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class GameViewController: UIViewController {
    
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
    var cameraPositionStart = SCNVector3(x: -1.176, y: 119.345, z: 31.818)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupNode()
        setupCamera()
        setupGestures()
//        setUpAudioCapture()
        playAmbience()
    }
    
    //SETUP SCENE
    func setupNode() {
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        ghostNode = scene.rootNode.childNode(withName: "wayangMonster reference", recursively: false)!
        roomNode = scene.rootNode.childNode(withName: "Room2 reference", recursively: true)!
        lightNode = scene.rootNode.childNode(withName: "omni", recursively: true)!
        bassNode = scene.rootNode.childNode(withName: "bass reference", recursively: false)
        safeNode = scene.rootNode.childNode(withName: "Safe reference", recursively: true)!
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
        
        tapRecognizer.addTarget(self, action: #selector(GameViewController.sceneViewTapped(recognizer:)))
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
                
                if self.db > -13 {
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
            }else if (tappedNode.name == "wall"){
                let moveAction = SCNAction.move(to: cameraPositionStart, duration: 1)
                cameraNode.runAction(moveAction)
            }
            
        }
    }
    
    func moveObjectToPlayerPosition() {
        print("\(cameraNode.convertPosition(cameraNode.position, to: scene.rootNode))")
        let position = cameraNode.convertPosition(cameraNode.position, to: scene.rootNode)
        
        let positionx = cameraNode.position.x
        let positiony = cameraNode.position.y - 16
        let positionz = cameraNode.position.z + 14
        
        let position2 = SCNVector3(x: positionx, y: positiony, z: positionz)
        
        let moveAction = SCNAction.move(to: position2, duration: 0.05)
        ghostNode.runAction(moveAction)
    }
    
    func audioTriggered() {
        print("Triggered: \(String(describing: db))")
        let playerPosition = cameraNode.position
        print("ghost: \(ghostNode.position)")
        print("player: \(cameraNode.position)")
        
        moveObjectToPlayerPosition()
    }
    
//    func openSafeDoor() {
//        let rotateAction = SCNAction.rotateTo(x: (90 * .pi / 180), y: (0 * .pi / 180), z: 0, duration: 1.5)
//        rotateAction.timingMode = .easeInEaseOut
//        self.safeDoorNode.runAction(rotateAction)
//    }
//    
//    func closeSafeDoor() {
//        let gearRotationAction = SCNAction.rotateTo(x: 0, y: -(90 * .pi / 180), z: 0, duration: 1)
//        let rotateAction = SCNAction.rotateTo(x: (90 * .pi / 180), y: -(90 * .pi / 180), z: 0, duration: 1.5)
//        
//        rotateAction.timingMode = .easeInEaseOut
//        gearRotationAction.timingMode = .easeInEaseOut
//        
//        self.safeDoorNode.runAction(rotateAction)
//    }
}

