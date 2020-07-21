//
//  SpriteUIHandler.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 12/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit


final class SpriteUIHandler {
    
    weak var scene: GameScene?
    weak var mapController: MapController?
    
    init(scene: GameScene, mapController: MapController) {
        self.scene = scene
        self.mapController = mapController
    }
    
    func addMovementArrows(to entity: RLEntity) {
        
        func createArrow(spriteName: String, movementDirection: Coord, positionDelta: CGPoint, animationDirection: CGVector) -> SKSpriteNode {
            if let tex = RLSprites.getSpriteTextureFor(tileName: spriteName) {
                tex.filteringMode = .nearest
                let arrow = SKSpriteNode(texture: tex)
                arrow.name = spriteName
                arrow.zPosition = 50
                arrow.position = positionDelta
                let bounceAction = SKAction.move(by: animationDirection, duration: 0.5)
                let moveAction = SKAction.repeatForever(SKAction.sequence([bounceAction, bounceAction.reversed()]))
                arrow.run(moveAction)
                
                let clickAction = { [weak self] in
                    guard let updatedEntity = self?.scene?.boxedWorld.world.entities[entity.id] else {
                        return
                    }
                    
                    //self?.scene?.boxedWorld.world.moveEntity(entity: updatedEntity, newPosition: updatedEntity.position + movementDirection)
                    self?.scene?.boxedWorld.update()
                    return
                }
                
                if arrow.userData != nil {
                    arrow.userData?["onClick"] =  clickAction
                } else {
                    arrow.userData = ["onClick": clickAction]
                }
                
                return arrow
            }
            return SKSpriteNode()
        }
        
        guard let sprite = mapController?.entityNodeMap[entity.id] else {
            print("Could not find sprite for entity \(entity)")
            return
        }
            
        let cellSize = scene?.cellSize ?? 0
        sprite.addChild(createArrow(spriteName: "LeftArrow_Short_OL", movementDirection: Coord(-1, 0), positionDelta: CGPoint(x: -cellSize, y: 0), animationDirection: CGVector(dx: -2, dy: 0)))
        sprite.addChild(createArrow(spriteName: "DownArrow_Short_OL", movementDirection: Coord(0, -1),positionDelta: CGPoint(x: 0, y: -cellSize), animationDirection: CGVector(dx: 0, dy: -2)))
        sprite.addChild(createArrow(spriteName: "RightArrow_Short_OL", movementDirection: Coord(1, 0), positionDelta: CGPoint(x: cellSize, y: 0), animationDirection: CGVector(dx: 2, dy: 0)))
        sprite.addChild(createArrow(spriteName: "UpArrow_Short_OL", movementDirection: Coord(0, 1), positionDelta: CGPoint(x: 0, y: cellSize), animationDirection: CGVector(dx: 0, dy: 2)))
    }
    
}
