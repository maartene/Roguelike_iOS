//
//  DropItemAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 31/12/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct DropItemAction: Action {
    let owner: RLEntity
    let item: RLEntity
    let title = "Drop"
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("DropItemAction: owner no longer exists in the world.")
            return false
        }
        
        guard let ic = actor.inventoryComponent else {
            print("DropItemAction: owner does not have an InventoryComponent.")
            return false
        }
        
        guard ic.items.contains(where: {$0.id == item.id}) else {
            print("DropItemAction: item is not in inventory of owner.")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard canExecute(in: world) else {
            print("DropItemAction: canExecute(in:) check failed.")
            return []
        }
        
        guard let actor = world.entities[owner.id] else {
            print("DropItemAction: owner no longer exists in the world.")
            return []
        }
        
        guard let ic = actor.inventoryComponent else {
            print("DropItemAction: owner does not have an InventoryComponent.")
            return []
        }
        
        let changedActor = ic.removeItem(item)
        var changedItem = item
        changedItem.position = actor.position
        return [changedActor, changedItem]
    }
    
}
