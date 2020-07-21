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
    
    fileprivate init(owner: RLEntity) {
        self.owner = owner
    }
    
    static func add(to entity: RLEntity) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["ActC"] = true
        
        return changedEntity
    }
    
    func getActionsFor(entity: RLEntity, on map: Map) -> [Action] {
        var actions = [Action]()
        if entity.id == owner.id {
            
        } else {
            actions.append(MoveAction(owner: owner, targetLocation: entity.position, map: map))
            if let attackComponent = owner.attackComponent {
                actions.append(AttackAction(owner: owner, damage: attackComponent.damage, target: entity))
            }
        }
        actions.append(WaitAction(owner: entity))
        return actions
    }
    
    func getActionFor(tile: Coord, on map: Map) -> [Action] {
        var actions = [Action]()
        if tile == owner.position {
            
        } else {
            actions.append(MoveAction(owner: owner, targetLocation: tile, map: map ))
        }
        actions.append(WaitAction(owner: owner))
        return actions
    }
}

extension RLEntity {
    var actionComponent: ActionComponent? {
        guard (variables["ActC"] as? Bool) ?? false == true else {
                return nil
        }
        
        return ActionComponent(owner: self)
    }
}
