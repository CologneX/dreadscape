//
//  GameView.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI
import SceneKit

struct ModernGameControllerWrapper: UIViewControllerRepresentable {
    var multipeer: MultipeerManager
    
    func makeUIViewController(context: Context) -> ModernGameController {
        let controller = ModernGameController()
        controller.multipeerManager = multipeer
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ModernGameController, context: Context) {}
}


struct ModernGameView: View {
    var multipeer: MultipeerManager
    
    var body: some View {
        ModernGameControllerWrapper(multipeer: multipeer)
            .edgesIgnoringSafeArea(.all)
    }
}
