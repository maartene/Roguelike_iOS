//
//  InfoView.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 02/01/2021.
//  Copyright © 2021 thedreamweb. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    
    @ObservedObject var scene: GameScene
    let fontSize: CGFloat = 32
    
    var info: String {
        if let tile = scene.selectedNode?.userData?["position"] as? Coord {
            let mapCell = scene.boxedWorld.world
                .currentFloor.map[tile]
            return "\(mapCell.name) - \(tile.description)"
        } else if let entityID = scene.selectedNode?.userData?["entityID"] as? UUID {
            if let entity = scene.boxedWorld.world.entities[entityID] {
                if let level = entity.variables["SC_currentLevel"] as? Int {
                    return "\(entity.name) - Lv. \(level)"
                } else {
                    return "\(entity.name)"
                }
            }
        }
        return ""
    }
    
    var body: some View {
        Text(info).font(.custom("Menlo-Regular", size: self.fontSize)).foregroundColor(Color.white)
            .background(Color.black.opacity(0.75))
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        let scene = GameScene()
        InfoView(scene: scene)
    }
}
