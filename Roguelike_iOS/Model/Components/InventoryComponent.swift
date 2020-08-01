//
//  InventoryComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 25/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct InventoryComponent {
    let owner: RLEntity
    
    var size: Int
    var items: [RLEntity]
    var pickupRange: Int
    var gold: Int
    
    fileprivate init(owner: RLEntity, size: Int, pickupRange: Int, gold: Int, items: [RLEntity]) {
        self.owner = owner
        self.size = size
        self.items = items
        self.pickupRange = pickupRange
        self.gold = gold
    }
    
    static func add(to entity: RLEntity, size: Int, pickupRange: Int, gold: Int = 0) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["IC"] = true
        changedEntity.variables["IC_size"] = size
        changedEntity.variables["IC_pickupRange"] = pickupRange
        changedEntity.variables["IC_gold"] = gold
        changedEntity.variables["IC_items"] = [RLEntity]()
        
        return changedEntity
    }
    
    func addItem(_ item: RLEntity) -> RLEntity {
        guard item.consumableEffect != nil || item.equipableEffect != nil else {
            print("ItemComponent: addItem - trying to add an entity without a consumable effect nor equipment. This entity cannot be added to inventory as it is not an item.")
            return owner
        }
        
        var changedItems = items
        if items.count < size {
            changedItems.append(item)
        }
        
        var changedEntity = owner
        changedEntity.variables["IC_items"] = changedItems
        
        return changedEntity
    }
    
    func removeItem(_ item: RLEntity) -> RLEntity {
        guard items.contains(where: {$0.id == item.id }) else {
            print("ItemComponent - removeItem - trying to remove an item that is not part of inventory.")
            return owner
        }
        
        var changedItems = items
        changedItems.removeAll(where: {$0.id == item.id })
        var changedEntity = owner
        changedEntity.variables["IC_items"] = changedItems
        return changedEntity
    }
    
    func addGold(_ amount: Int) -> RLEntity {
        var changedEntity = owner
        changedEntity.variables["IC_gold"] = gold + amount
        return changedEntity
    }
    
    func removeGold(_ amount: Int) -> RLEntity {
        guard gold >= amount else {
            return owner
        }
        
        var changedEntity = owner
        changedEntity.variables["IC_gold"] = gold - amount
        return changedEntity
    }
}

extension RLEntity {
    var inventoryComponent: InventoryComponent? {
        guard self.variables["IC"] as? Bool ?? false == true,
            let items = variables["IC_items"] as? [RLEntity],
            let size = variables["IC_size"] as? Int,
            let gold = variables["IC_gold"] as? Int,
            let pickupRange = variables["IC_pickupRange"] as? Int else {
            return nil
        }
    
        return InventoryComponent(owner: self, size: size, pickupRange: pickupRange, gold: gold, items: items)
    }
}
