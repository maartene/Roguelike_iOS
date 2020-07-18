//
//  MoveAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 14/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct MoveAction: Action {
    let owner: RLEntity
    let title = "Move to"
    let description = "Move to the target location. This uses 1 action points per 2 tiles movement."
    let targetLocation: Coord
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("ACTION: Owner no longer exists in the world.")
            return false
        }
        
        guard targetLocation != actor.position else {
            print("ACTION: Already on target location..")
            return false
        }
        
        guard actor.visibilityComponent?.visibleTiles.contains(targetLocation) ?? false else {
            print("ACTION: Target location is not visible.")
            return false
        }
        
        let distance = targetLocation.manhattanDistance(to: actor.position)
        let cost = max(distance / 2, 1)
        
        guard cost <= actor.actionComponent?.currentAP ?? 0 else {
            print("ACTION: Not enough action points. (requires \(cost), \(actor.name) has \(actor.actionComponent?.currentAP ?? 0)")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard canExecute(in: world) else {
            print("NO EFFECT: Cannot execute action: \(self)")
            return []
        }
        
        guard var updatedActor = world.entities[owner.id] else {
            print("NO EFFECT: Owner no longer exists in the world.")
            return []
        }
        
        let distance = targetLocation.manhattanDistance(to: updatedActor.position)
        
        print("Move took \(distance)")
        updatedActor.position = targetLocation
        updatedActor = updatedActor.actionComponent?.spendAP(amount: max(1, distance / 2)) ?? updatedActor
        updatedActor = updatedActor.visibilityComponent?.update(entity: updatedActor, in: world).first ?? updatedActor
        
        return [updatedActor]
    }
    
    
}
