//
//  GameView.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI
import SceneKit

struct GameViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}

struct GameView: View {
    var body: some View {
        GameViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}
