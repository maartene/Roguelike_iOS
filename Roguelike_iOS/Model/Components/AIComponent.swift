//
//  AIComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 19/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct AIComponent {
    let owner: RLEntity
    
    fileprivate init(owner: RLEntity) {
        self.owner = owner
    }
    
    static func add(to entity: RLEntity) -> RLEntity {
        var changedEntity = entity
        changedEntity.variables["AIC"] = true
        return changedEntity
    }
    
    /*func update(entity: RLEntity, in world: World) -> [RLEntity] {
        guard let vc = entity.visibilityComponent, var actc = entity.actionComponent, let ac = entity.attackComponent else {
            return []
        }
        var updatedWorld = world
        var updatedEntity = entity
        // if entity can see the player
        if vc.visibleTiles.contains(world.player.position) {
            while updatedEntity.actionComponent?.currentAP ?? 0 > 0 {
                // are we close enough to attack the player?
                if updatedEntity.position.manhattanDistance(to: world.player.position) <= ac.range {
                    // close enough, lets attack!
                    let attackAction = AttackAction(owner: updatedEntity, damage: ac.damage, target: world.player)
                    let attackResultEntities = attackAction.execute(in: updatedWorld)
                    updatedWorld.replaceEntities(entities: attackResultEntities)
                } else {
                    // need to move closer
                    let moveAction = MoveAction(owner: updatedEntity, targetLocation: world.player.position)
                    let moveActionResults = moveAction.execute(in: updatedWorld)
                    updatedWorld.replaceEntities(entities: moveActionResults)
                }
                
                updatedEntity = updatedWorld.entities[updatedEntity.id] ?? updatedEntity
                //print("Updated entity: \(updatedEntity)")
                
            }
        }
        return Array(updatedWorld.entities.values)
    }*/
}

extension RLEntity {
    var aiComponent: AIComponent? {
        guard (variables["AIC"] as? Bool) ?? false == true else {
            return nil
        }
        
        return AIComponent(owner: self)
    }
}
