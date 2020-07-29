//
//  EquipmentActions.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 27/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct EquipFromInventoryAction: Action {
    let owner: RLEntity
    let title = "Equip"
    let item: RLEntity
    let slot: EquipmentSlot
    
    var description: String {
        "Equip in \(item.name) in slot \(slot)."
    }
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Owner no longer exists in the world.")
            return false
        }
        
        guard let ec = actor.equipmentComponent else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Owner does not have an EquipmentComponent.")
            return false
        }
        
        guard let ic = actor.inventoryComponent else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Owner does not have an InventoryComponent.")
            return false
        }
        
        guard let eec = item.equipableEffect else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Item does not have an EquipableEffectComponent.")
            return false
        }
        
        guard ic.items.contains(where: {$0.id == item.id}) else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Item is not in owners inventory.")
            return false
        }
        
        guard eec.occupiesSlot == slot else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Wrong slot type \(slot) for item \(item.name).")
            return false
        }
                
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard let actor = world.entities[owner.id] else {
            print("EquipFromInventoryAction: CANNOT EXECUTE: Owner no longer exists in the world.")
            return []
        }
        
        guard canExecute(in: world) else {
            print("EquipFromInventoryAction: CANNOT EXECUTE")
            return []
        }
        
        var changedEntity = actor
        
        // is the intended equipment slot empty?
        //print(changedEntity.equipmentComponent!.slotIsEmpty(slot))
        if changedEntity.equipmentComponent!.slotIsEmpty(slot) {
            changedEntity = changedEntity.inventoryComponent?.removeItem(item) ?? changedEntity
            changedEntity = changedEntity.equipmentComponent?.equipItem(item, in: slot) ?? changedEntity
        } else {
            // the equipementslot is not empty, we need to remove the current item first
            let unequipResult = changedEntity.equipmentComponent!.unequipItem(in: slot)
            if let unequippedItem = unequipResult.item {
                changedEntity = unequipResult.updatedEntity.inventoryComponent?.removeItem(item) ?? changedEntity
                changedEntity = changedEntity.equipmentComponent?.equipItem(item, in: slot) ?? changedEntity
                changedEntity = changedEntity.inventoryComponent?.addItem(unequippedItem) ?? changedEntity
            }
        }
        
        return [changedEntity]
    }
}

struct UnequipToInventoryAction: Action {
    let owner: RLEntity
    let title = "Unequip"
    var description: String {
        "Unequip the item in slot \(slot). It will be placed in your inventory."
    }
    var slot: EquipmentSlot
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("UnequipToInventoryAction: CANNOT EXECUTE: Owner no longer exists in the world.")
            return false
        }
        
        guard let ec = actor.equipmentComponent else {
            print("UnequipToInventoryAction: CANNOT EXECUTE: Owner does not have an EquipmentComponent.")
            return false
        }
        
        guard let ic = actor.inventoryComponent else {
            print("UnequipToInventoryAction: CANNOT EXECUTE: Owner does not have an InventoryComponent.")
            return false
        }
        
        guard ic.items.count < ic.size else {
            print("UnequipToInventoryAction: CANNOT EXECUTE: No room in inventory.")
            return false
        }
        
        guard ec.slotIsEmpty(slot) == false else {
            print("UnequipToInventoryAction: CANNOT EXECUTE: Slot \(slot) is empty.")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard let actor = world.entities[owner.id] else {
            print("UnequipToInventoryAction: CANNOT EXECUTE: Owner no longer exists in the world.")
            return []
        }
        
        guard canExecute(in: world) else {
            print("UnequipToInventoryAction: CANNOT EXECUTE.")
            return []
        }
        
        guard let unequipResult = actor.equipmentComponent?.unequipItem(in: slot) else {
            return []
        }
        
        var changedEntity = unequipResult.updatedEntity
        if let item = unequipResult.item {
            changedEntity = changedEntity.inventoryComponent?.addItem(item) ?? changedEntity
        }
        
        return [changedEntity]
    }
}
