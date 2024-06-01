//
//  DreadscapeApp.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI
@main
struct DreadscapeApp: App {
    // App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup{
            PairingView()
        }
    }
}
