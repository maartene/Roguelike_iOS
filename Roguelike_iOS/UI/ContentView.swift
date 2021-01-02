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
            if let actions = boxedWorld.world.player.actionComponent?.getActionFor(tile: tile, on: boxedWorld.world.currentFloor.map) {
                return actions
            }
        } else if let entityID = scene.selectedNode?.userData?["entityID"] as? UUID {
            if let entity = boxedWorld.world.entities[entityID] {
                if let actions = boxedWorld.world.player.actionComponent?.getActionsFor(entity: entity, on: boxedWorld.world.currentFloor.map) {
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
            }
            
            HStack {
                SpendStatPointsViewContainer(boxedWorld: self.scene.boxedWorld)
                Spacer()
            }
            HStack {
                Spacer()
                InventoryViewContainer(boxedWorld: self.scene.boxedWorld)
            }
            VStack {
                Spacer()
                
                HStack {
                    Text("Floor: \(self.scene.boxedWorld.world.currentFloorIndex) Entities: \(self.scene.boxedWorld.world.entitiesOnCurrentFloor.count) /  \(self.scene.boxedWorld.world.entities.count)     ").font(.custom("Menlo-Regular", size: 24)).foregroundColor(Color.white)
                    Button(action: { self.scene.boxedWorld.save()}, label: { Text("[ Save ]")}).disabled(boxedWorld.state != .idle)
                        .font(.custom("Menlo-Regular", size: 24)).background(Color.yellow)
                    Text(" ").font(.custom("Menlo-Regular", size: 24))
                    Button(action: { self.scene.load()}, label: { Text("[ Load ]")}).disabled(boxedWorld.state != .idle)
                        .font(.custom("Menlo-Regular", size: 24)).background(Color.yellow)
                    /*Button(action: { self.scene.newGame()}, label: { Text("[ New Game ]")}).disabled(boxedWorld.state != .idle)
                    .font(.custom("Menlo-Regular", size: 24)).background(Color.yellow)*/
                }
            }
            
            if scene.selectedNode != nil && action.count > 0 {
                ActionsView(boxedWorld: boxedWorld, offset: scene.selectedNode!.position, title: "ACTIONS:", actions: action, sceneSize: scene.size)
            }
            
            VStack {
                Spacer()
                HStack {
                    InfoView(scene: scene)
                    Spacer()
                }
            }
            
            if boxedWorld.state == .loading || boxedWorld.state == .saving {
                Color.black.opacity(0.75)
                Text("\(boxedWorld.state.rawValue) - please wait").foregroundColor(Color.white).font(.custom("Menlo-Regular", size: 36))
            }
            if boxedWorld.state == .gameover {
                Color.black.opacity(0.75)
                VStack {
                    Text("You died...").foregroundColor(Color.white).font(.custom("Menlo-Regular", size: 36))
                    
                    Button(action: {
                        //self.scene.mapController.floorToShow = 0
                        self.scene.newGame()
                    }, label: { Text("[ New game ]") }).font(.custom("Menlo-Regular", size: 24)).background(Color.yellow).padding(.top)
                }
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
