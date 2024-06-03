//
//  AstralGameView.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 03/06/24.
//

import SwiftUI
import SceneKit

struct AstralGameControllerWrapper: UIViewControllerRepresentable {
    var multipeer: MultipeerManager
    
    func makeUIViewController(context: Context) -> AstralGameController {
        let controller = AstralGameController()
        controller.multipeerManager = multipeer
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AstralGameController, context: Context) {}
}

struct AstralGameView: View {
    var multipeer: MultipeerManager
    
    var body: some View {
        AstralGameControllerWrapper(multipeer: multipeer)
            .edgesIgnoringSafeArea(.all)
    }
}
