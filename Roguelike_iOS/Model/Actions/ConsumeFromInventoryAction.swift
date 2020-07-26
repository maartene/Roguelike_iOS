//
//  ConsumeFromInventoryAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 26/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct ConsumeFromInventoryAction: Action {
    let owner: RLEntity

    let title = "Consume"
    var description: String {
        "Consume \(item.name)."
    }
    
    let item: RLEntity

    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("ConsumeFromInventoryAction: Owner no longer exists in the world.")
            return false
        }
        
        guard let ic = actor.inventoryComponent else {
            print("ConsumeFromInventoryAction: Owner does not haven InventoryComponent.")
            return false
        }
        
        guard ic.items.contains(where: {$0.id == item.id}) else {
            print("ConsumeFromInventoryAction: Owner's inventory does not contain \(item.name) \(item.id).")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard canExecute(in: world) else {
            print("ConsumeFromInventoryAction: Cannot Execute command.")
            return []
        }
        
        guard let actor = world.entities[owner.id] else {
            return []
        }
        
        if let consumeResult = item.consumableEffect?.consume(target: actor) {
            let changedOwner = consumeResult.updatedTarget.inventoryComponent?.removeItem(item) ?? actor
            
            //var consumedItem = consumeResult.consumedItem
            return [changedOwner]
        }
        return []
    }
    
}
