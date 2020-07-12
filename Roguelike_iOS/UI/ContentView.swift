//
//  ContentView.swift
//  RogueLike_Catalyst
//
//  Created by Maarten Engels on 09/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct StateView: View {
    @ObservedObject var boxedWorld: WorldBox
    
    var body: some View {
        ZStack {
            background(Color.black).opacity(boxedWorld.state == .idle ? 0 : 0.5)
            Text("Busy \(boxedWorld.state.rawValue)").foregroundColor(Color.white).opacity(boxedWorld.state == .idle ? 0 : 0.5)
        }
        
    }
}

struct HUD: View {
    @ObservedObject var scene: GameScene
    
    var body: some View {
        ZStack {
            VStack {
                PlayerStatisticsView(boxedWorld: self.scene.boxedWorld)
                Spacer()
                HStack {
                    Button(action: { self.scene.boxedWorld.save()}, label: { Text("Save")}).disabled(scene.worldState != .idle)
                    Button(action: { self.scene.load()}, label: { Text("Load")}).disabled(scene.worldState != .idle)
                }
            }
            /*if scene.worldState == .loading {
                background(Color.black).opacity(0.5)
                Text("Loading")
            }*/
        }
    }
}

struct ContentView: View {
    
    var scene: GameScene
    
    var body: some View {
        ZStack {
            SpriteKitView(scene: self.scene)
            HUD(scene: self.scene)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let scene = GameScene()
        return ContentView(scene: scene)
    }
}
