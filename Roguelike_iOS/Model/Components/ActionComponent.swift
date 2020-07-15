//
//  ActionComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 14/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct ActionComponent {
    let owner: RLEntity
    let maxAP: Int
    let currentAP: Int
    
    fileprivate init(owner: RLEntity, maxAP: Int, currentAP: Int) {
        self.owner = owner
        self.maxAP = maxAP
        self.currentAP = currentAP
    }
    
    static func add(to entity: RLEntity, maxAP: Int, currentAP: Int) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["ActC"] = true
        changedEntity.variables["ActC_maxAP"] = maxAP
        changedEntity.variables["ActC_currentAP"] = min(maxAP, currentAP)
        
        return changedEntity
    }
    
    func update(entity: RLEntity, in world: World) -> [RLEntity] {
        var updatedAP = currentAP + 2
        updatedAP = min(maxAP, updatedAP)
        
        var changedEntity = entity
        changedEntity.variables["ActC_currentAP"] = updatedAP
        return [changedEntity]
    }
    
    func getActionsFor(entity: RLEntity) -> [Action] {
        return []
    }
    
    func getActionFor(tile: Coord) -> [Action] {
        return [MoveAction(targetLocation: tile), WaitAction()]
    }
    
    func spendAP(amount: Int) -> RLEntity {
        var updatedOwner = owner
        
        updatedOwner.variables["ActC_currentAP"] = currentAP - amount
        
        return updatedOwner
    }
}

extension RLEntity {
    var actionComponent: ActionComponent? {
        guard (variables["ActC"] as? Bool) ?? false == true,
            let maxAP = variables["ActC_maxAP"] as? Int,
            let currentAP = variables["ActC_currentAP"] as? Int else {
                return nil
        }
        
        return ActionComponent(owner: self, maxAP: maxAP, currentAP: currentAP)
    }
}
