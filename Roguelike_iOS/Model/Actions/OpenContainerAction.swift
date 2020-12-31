//
//  OpenContainerAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 31/12/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct OpenContainerAction: Action {
    let owner: RLEntity
    let title = "Open"
    let description = "Open container"
    let itemContainer: RLEntity
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("OpenContainerAction - CANNOT EXECUTE: owner no longer exists in the world.")
            return false
        }
        
        guard let ic = actor.inventoryComponent else {
            print("OpenContainerAction - CANNOT EXECUTE: owner does not have an inventory component.")
            return false
        }
        
        guard world.entities.contains(where: {$0.key == itemContainer.id}) else {
            print("OpenContainerAction - CANNOT EXECUTE: item container doesn't exists in the world (any longer).")
            return false
        }
        
        let sqrDistance = Coord.sqr_distance(itemContainer.position, owner.position)
        guard sqrDistance <= Double(ic.pickupRange * ic.pickupRange) else {
            print("OpenContainerAction - CANNOT EXECUTE: Container out of range.")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard canExecute(in: world) else {
            print("OpenContainerAction - CANNOT EXECUTE: canExecute(in:) check failed.")
            return []
        }
        
        guard var actor = world.entities[owner.id] else {
            print("OpenContainerAction - CANNOT EXECUTE: owner no longer exists in the world.")
            return []
        }
        
        guard var itemContainer = world.entities[itemContainer.id] else {
            print("OpenContainerAction - CANNOT EXECUTE: item container doesn't exists in the world (any longer).")
            return []
        }
        
        guard let icc = itemContainer.itemContainerComponent else {
            print("OpenContainerAction - CANNOT EXECUTE: item container does not contain an item container component.")
            return []
        }
        
        for item in icc.loot {
            actor = actor.inventoryComponent?.addItem(item) ?? actor
        }
        itemContainer.variables["SHOULD_REMOVE"] = true
        
        return [actor, itemContainer, icc.replaceComponent]
    }
}
