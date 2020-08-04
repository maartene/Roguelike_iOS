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
    let description = "Move to the target location."
    let targetLocation: Coord
    let map: Map
    let ignoreVisibility: Bool
    
    init(owner: RLEntity, targetLocation: Coord, map: Map, ignoreVisibility: Bool = false) {
        self.owner = owner
        self.targetLocation = targetLocation
        self.map = map
        self.ignoreVisibility = ignoreVisibility
    }
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("ACTION: Owner no longer exists in the world.")
            return false
        }
        
        guard targetLocation != actor.position else {
            print("ACTION: Already on target location..")
            return false
        }
        
        guard map[targetLocation].enterable else {
            print("ACTION: Target location is not enterable.")
            return false
        }
        
        guard actor.visibilityComponent?.visibleTiles.contains(targetLocation) ?? false || ignoreVisibility else {
            print("ACTION: Target location is not visible.")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard canExecute(in: world) else {
            print("NO EFFECT: Cannot execute action: \(self.title) targetLocation: \(self.targetLocation)")
            return []
        }
        
        guard var updatedActor = world.entities[owner.id] else {
            print("NO EFFECT: Owner no longer exists in the world.")
            return []
        }
        
        updatedActor.position = targetLocation
        updatedActor = updatedActor.visibilityComponent?.update(in: world) ?? updatedActor
        
        return [updatedActor]
    }
    
    func unpack() -> [Action] {
        // FIXME: this should be based on proper pathfinding, instead on a direct line.
        
        if owner.position.manhattanDistance(to: targetLocation) > 1 {
            var line = Coord.plotLine(from: owner.position, to: targetLocation)
            
            if line.count > 1 {
                line.removeFirst()
            }
            
            let actions = line.map { coord in MoveAction(owner: owner, targetLocation: coord, map: map, ignoreVisibility: ignoreVisibility) }
            if actions.contains(where: { action in map[action.targetLocation].enterable == false }) {
                return []
            } else {
                return actions
            }
            
        } else {
            return [self]
        }
    }
}
