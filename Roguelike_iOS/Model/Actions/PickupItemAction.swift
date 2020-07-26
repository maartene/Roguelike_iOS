//
//  PickupItemAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 26/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct PickupAction: Action {
    let owner: RLEntity
    let item: RLEntity
    let title = "Pick up"
    
    var description: String {
        "Pick up \(item.name)."
    }
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("PickupAction: owner no longer exists in the world.")
            return false
        }
        
        guard let ic = actor.inventoryComponent else {
            print("PickupAction: owner does not have an InventoryComponent.")
            return false
        }
        
        guard let item = world.entities[item.id] else {
            print("PickupAction: item no longer exists in the world.")
            return false
        }
        
        guard item.consumableEffect != nil else {
            print("PickupAction: \(item.name) is not an item.")
            return false
        }
        
        guard ic.items.count < ic.size else {
            print("PickupAction: Inventory full")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard canExecute(in: world) else {
            print("PickupAction - NO EFFECT: Cannot execute command.")
            return []
        }
        
        guard var actor = world.entities[owner.id] else {
            return []
        }
        
        actor = actor.inventoryComponent?.addItem(item) ?? actor
        var pickedUpItem = item
        pickedUpItem.variables["SHOULD_REMOVE"] = true
        
        // print("Picked up item: \(pickedUpItem). Inventory now contains: \(actor.inventoryComponent?.items ?? [])")
        
        return [actor, pickedUpItem]
    }
    
}
