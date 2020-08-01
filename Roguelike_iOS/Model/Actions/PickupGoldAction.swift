//
//  PickupGoldAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 01/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct PickupGoldAction: Action {
    let owner: RLEntity
    let title = "Pickup"
    var description: String {
        "Pickup \(goldEntity.goldComponent?.amount ?? 0) gold."
    }
    let goldEntity: RLEntity
    
    func canExecute(in world: World) -> Bool {
        guard let goldEntity = world.entities[goldEntity.id] else {
            print("PickupGoldAction - CANNOT EXECUTE: gold entity no longer exists in the world.")
            return false
        }
        
        guard let actor = world.entities[owner.id] else {
            print("PickupGoldAction - CANNOT EXECUTE: owner no longer exists in the world.")
            return false
        }
        
        guard actor.inventoryComponent != nil else {
            print("PickupGoldAction - CANNOT EXECUTE: owner does not have an InventoryComponent (to store the gold).")
            return false
        }
        
        guard goldEntity.goldComponent != nil else {
            print("PickupGoldAction - CANNOT EXECUTE: gold entity does not have a GoldComponent.")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard let actor = world.entities[owner.id] else {
            print("PickupGoldAction - CANNOT EXECUTE: owner no longer exists in the world.")
            return []
        }
        
        guard canExecute(in: world) else {
            print("PickupGoldAction - CANNOT EXECUTE: canExecute check failed. See details above.")
            return []
        }
        
        let changedActor = actor.inventoryComponent?.addGold(goldEntity.goldComponent?.amount ?? 0) ?? actor
        var pickedupGold = goldEntity
        pickedupGold.variables["SHOULD_REMOVE"] = true
        
        return [changedActor, pickedupGold]
    }
}
