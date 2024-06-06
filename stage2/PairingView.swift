//
//  PairingView.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI
import AVFoundation
import AVKit

class SoundManager {
    static let instance = SoundManager()
    
    private var audioPlayers: [AVAudioPlayer] = []
    private var click1URL: URL?
    private var click2URL: URL?
    private var clickConfirmURL: URL?
    
    init() {
        click1URL = Bundle.main.url(forResource: "typewriterClick1", withExtension: "mp3")
        click2URL = Bundle.main.url(forResource: "typewriterClick2", withExtension: "mp3")
        clickConfirmURL = Bundle.main.url(forResource: "typewriterConfirm", withExtension: "mp3")
        
        if let click1URL = click1URL, let click2URL = click2URL, let clickConfirmURL = clickConfirmURL {
            do {
                let player1 = try AVAudioPlayer(contentsOf: click1URL)
                let player2 = try AVAudioPlayer(contentsOf: click2URL)
                let playerConfirm = try AVAudioPlayer(contentsOf: clickConfirmURL)
                
                audioPlayers.append(player1)
                audioPlayers.append(player2)
                audioPlayers.append(playerConfirm)
                
            } catch {
                print("Error loading sound files.")
            }
        }
    }
    
    private func playSound(_ sound: AVAudioPlayer) {
        sound.prepareToPlay()
        sound.play()
    }
    
    func playRandomClick() {
        let randomIndex = Int.random(in: 0...1)
        let sound = audioPlayers[randomIndex]
        playSound(sound)
    }
    
    func playConfirmClick() {
        let sound = audioPlayers[2]
        playSound(sound)
    }
}

struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let url = Bundle.main.url(forResource: "pairingTransition", withExtension: "mov")!
        let player = AVPlayer(url: url)
        player.play()
        
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
    }
}

struct PairingView: View {
    @ObservedObject var multipeer: MultipeerManager
    let buttonImages = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "keyBlank", "keyCancel", "keyConfirm"]
    @State private var buttonPressed = Array(repeating: false, count: 13)
    @State var pairingCode: String = ""
    @State private var showTransitionVideo = false
    private func appendCode(_ code: String, at index: Int){
        if pairingCode.count < 6 {
            pairingCode.append(code)
        }
        withAnimation(.easeInOut(duration: 0.1)) {
            buttonPressed[index] = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                buttonPressed[index] = false
            }
        }
    }
    private func submitPasscodeMultipeer(){
        self.multipeer.pairingCode = pairingCode
        self.multipeer.activate()
    }
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let buttonSize = geometry.size.width / 10 // Adjust the divisor to change button size ratio
                VStack {
                    Spacer()
                    ZStack(alignment: .topLeading) {
                        Image("KeyboardTextField")
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: buttonSize * 2)
                        Text(pairingCode)
                            .foregroundStyle(.black)
                            .bold()
                            .font(.custom("Cormorant Upright", size: buttonSize))
                            .frame(maxWidth: .infinity, maxHeight: buttonSize / 2)
                    }
                    Spacer()
                    VStack {
                        HStack(spacing: buttonSize / 5) {
                            Button {
                                self.appendCode("1", at: 0)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("1")
                                    .resizable()
                                    .frame(width: buttonSize , height: buttonSize )
                                    .scaleEffect(buttonPressed[0] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize)
                            
                            Button {
                                self.appendCode("2", at: 1)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("2")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[1] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize / 2)
                            Button {
                                self.appendCode("3", at: 2)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("3")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[2] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize / 4)
                            Button {
                                self.appendCode("4", at: 3)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("4")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[3] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize / 2)
                            Button {
                                self.appendCode("5", at: 4)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("5")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[4] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize)
                            
                        }
                        HStack(spacing: buttonSize / 5) {
                            Button {
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("keyBlank")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                            }
                            .offset(y: -buttonSize * 1.25)
                            Button {
                                self.appendCode("6", at: 5)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("6")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[5] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize * 0.75)
                            Button {
                                self.appendCode("7", at: 6)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("7")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[6] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize / 4)
                            Button {
                                self.appendCode("8", at: 7)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("8")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[7] ? 0.8 : 1.0)
                            }
                            Button {
                                self.appendCode("9", at: 8)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("9")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[8] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize / 4)
                            Button {
                                self.appendCode("0", at: 9)
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("0")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .scaleEffect(buttonPressed[9] ? 0.8 : 1.0)
                            }
                            .offset(y: -buttonSize * 0.75)
                            Button {
                                if pairingCode.count > 0 {
                                    pairingCode.removeLast()
                                }
                                SoundManager.instance.playRandomClick()
                            } label: {
                                Image("keyCancel")
                                    .resizable()
                                    .frame(width: buttonSize, height: buttonSize)
                                
                            }
                            .offset(y: -buttonSize * 1.25)
                        }
                    }
                    Button {
                        SoundManager.instance.playConfirmClick()
                        showTransitionVideo = true
                        submitPasscodeMultipeer()
                    } label: {
                        Image("keyConfirm")
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: buttonSize)
                    }
                    .padding(.horizontal, buttonSize)
                    Spacer()
                }
                .padding(.horizontal, buttonSize)
            }
            if showTransitionVideo {
                PlayerView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    PairingView(multipeer: MultipeerManager(), pairingCode: "7")
}
