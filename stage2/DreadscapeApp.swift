//
//  DreadscapeApp.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI
import MultipeerConnectivity
@main
struct DreadscapeApp: App {
    // App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Multipeer Instance
    @ObservedObject var multipeer: MultipeerManager = MultipeerManager()
    
    var body: some Scene {
        WindowGroup{
            Group{
                switch self.multipeer.connectedPeer  {
                case .some:
                    ModernGameView(multipeer: multipeer)
                case .none:
                    PairingView(multipeer: multipeer)
                }
            }
        }
    }
}
