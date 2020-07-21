//
//  LensController.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 19/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import Combine

final class LensController {
    
    let node: SKEffectNode
    weak var scene: GameScene?
    weak var mapController: MapController?
    
    var cancellables = Set<AnyCancellable>()
    
    init(scene: GameScene, mapController: MapController) {
        self.scene = scene
        self.mapController = mapController
        
        node = SKEffectNode()
        node.blendMode = .add
        
        scene.addChild(node)
    }
    
    
}
