//
//  DreadscapeApp.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI
import AVKit
enum ChosenWorld {
    case Astral
    case Modern
}

@main
struct DreadscapeApp: App {
    // App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Multipeer Instance
    @ObservedObject var multipeer: MultipeerManager = MultipeerManager()
    @State var chosenWorld: ChosenWorld? = nil
    @State private var videoFinished = false
    var body: some Scene {
        WindowGroup {
            Group {
                contentView
            }
            .animation(.easeInOut, value: chosenWorld)
            .animation(.easeInOut, value: multipeer.connectedPeer)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let chosenWorld = chosenWorld {
            if let _ = multipeer.connectedPeer {
                gameView(for: chosenWorld)
                    .transition(.slide)
            } else {
                PairingView(multipeer: multipeer)
                    .transition(.slide)
            }
        } else {
            ChooseDoorView(chosenWorld: $chosenWorld)
                .transition(.slide)
        }
    }
    
    @ViewBuilder
    private func gameView(for world: ChosenWorld) -> some View {
        switch world {
        case .Astral:
            AstralGameView(multipeer: multipeer)
        case .Modern:
            ModernGameView(multipeer: multipeer)
        }
    }
}
