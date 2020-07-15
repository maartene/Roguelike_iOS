//
//  MoveAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 14/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct MoveAction: Action {
    let title = "Move to"
    let description = "Move to the target location. This uses 1 action points per 2 tiles movement."
    let targetLocation: Coord
    
    func canExecute(by actor: RLEntity, in world: World) -> Bool {
        guard targetLocation != actor.position else {
            return false
        }
        
        guard actor.visibilityComponent?.visibleTiles.contains(targetLocation) ?? false else {
            return false
        }
        
        let distance = targetLocation.manhattanDistance(to: actor.position)
        let cost = max(distance / 2, 1)
        
        guard cost <= actor.actionComponent?.currentAP ?? 0 else {
            return false
        }
        
        return true
    }
    
    func execute(by actor: RLEntity, in world: World) -> [RLEntity] {
        guard canExecute(by: actor, in: world) else {
            print("NO EFFECT: Cannot execute action: \(self)")
            return []
        }
        
        var updatedActor = actor
        
        let distance = targetLocation.manhattanDistance(to: actor.position)
        
        print("Move took \(distance)")
        updatedActor.position = targetLocation
        updatedActor = updatedActor.actionComponent?.spendAP(amount: max(1, distance / 2)) ?? updatedActor
        updatedActor = VisibilityComponent.update(entity: updatedActor, in: world).first ?? updatedActor
        
        return [updatedActor]
    }
    
    
}
