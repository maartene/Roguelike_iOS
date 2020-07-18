//
//  ContentView.swift
//  RogueLike_Catalyst
//
//  Created by Maarten Engels on 09/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct HUD: View {
    @ObservedObject var scene: GameScene
    @ObservedObject var boxedWorld: WorldBox
    
    var action: [Action] {
        if let tile = scene.selectedNode?.userData?["position"] as? Coord {
            if let actions = boxedWorld.world.player.actionComponent?.getActionFor(tile: tile) {
                return actions
            }
        } else if let entityID = scene.selectedNode?.userData?["entityID"] as? UUID {
            if let entity = boxedWorld.world.entities[entityID] {
                if let actions = boxedWorld.world.player.actionComponent?.getActionsFor(entity: entity) {
                    return actions
                }
            }
        }
        return []
    }
    
    var body: some View {
        ZStack {
            VStack {
                PlayerStatisticsView(boxedWorld: self.scene.boxedWorld)
                Spacer()
                HStack {
                    Button(action: { self.scene.boxedWorld.save()}, label: { Text("[ Save ]")}).disabled(boxedWorld.state != .idle)
                        .font(.custom("Menlo-Regular", size: 24)).background(Color.yellow)
                    Text(" ").font(.custom("Menlo-Regular", size: 24))
                    Button(action: { self.scene.load()}, label: { Text("[ Load ]")}).disabled(boxedWorld.state != .idle)
                        .font(.custom("Menlo-Regular", size: 24)).background(Color.yellow)
                }
            }
            
            if scene.selectedNode != nil {
                ActionsView(boxedWorld: boxedWorld, offset: scene.selectedNode!.position, title: "ACTIONS:", actions: action, sceneSize: scene.size)
            }
            
            
            if boxedWorld.state == .loading || boxedWorld.state == .saving {
                Color.black.opacity(0.75)
                Text("\(boxedWorld.state.rawValue) - please wait").foregroundColor(Color.white).font(.custom("Menlo-Regular", size: 36))
            }
        }
    }
}

struct ContentView: View {
    
    var scene: GameScene
    var boxedWorld: WorldBox
    
    var body: some View {
        ZStack {
            SpriteKitView(scene: self.scene)
            HUD(scene: self.scene, boxedWorld: boxedWorld)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let scene = GameScene()
        return ContentView(scene: scene, boxedWorld: scene.boxedWorld)
    }
}
