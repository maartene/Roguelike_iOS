//
//  SpriteKitView.swift
//  RogueLike_Catalyst
//
//  Created by Maarten Engels on 09/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI
import SpriteKit

struct SpriteKitView: UIViewRepresentable {
    let scene: GameScene

    func makeUIView(context: Context) -> SKView {
        // Let SwiftUI handle the sizing
        print("Creating View")
        let view = SKView(frame: .zero)
        
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        
        scene.scaleMode = .resizeFill
        
        view.presentScene(scene)
                
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        print("Updating view")
        
        //scene.updateMinimapPosition(view: uiView)
        
    }
    
    func makeCoordinator() -> SpriteKitView.Coordinator {
        print("Creating coordinator")
        return Coordinator(scene: scene)
    }
    
    final class Coordinator: NSObject, SKSceneDelegate {
        let scene: GameScene
        
        init(scene: GameScene) {
            self.scene = scene
        }
        
        func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            print("Pressed: \(presses)")
        }
    }
    
    final class GameView: SKView {
        override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            print("Pressed: \(presses)")
        }
    }
}

struct SpriteKitView_Previews: PreviewProvider {
    static var previews: some View {
        let scene = GameScene()
        return SpriteKitView(scene: scene)
    }
}
