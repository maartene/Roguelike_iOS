//
//  EquipmentComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 27/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct EquipmentComponent {
    let owner: RLEntity
    var equippedSlots: [EquipmentSlot: RLEntity?]
    
    fileprivate init(owner: RLEntity, equippedSlots: [EquipmentSlot: RLEntity?]) {
        self.owner = owner
        self.equippedSlots = equippedSlots
    }
    
    static func add(to entity: RLEntity, slots: Set<EquipmentSlot> = .init(arrayLiteral: .head, .body, .leftArm, .rightArm, .legs)) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["EC"] = true
        
        let equippedSlots: [EquipmentSlot: RLEntity?] = slots.reduce(into: [:], { result, next in
            result.updateValue(nil, forKey: next)
        })
        
        changedEntity.variables["EC_equippedSlots"] = equippedSlots
        
        return changedEntity
    }
    
    func slotIsEmpty(_ slot: EquipmentSlot) -> Bool {
        let slotContents = equippedSlots[slot, default: nil]
        return slotContents == nil
    }
    
    func equipItem(_ item: RLEntity, in slot: EquipmentSlot) -> RLEntity {
        guard let eec = item.equipableEffect else {
            print("EquipmentComponent: equipItem - trying to equip an entity without an EquipableEffectComponent.")
            return owner
        }
        
        guard eec.occupiesSlot == slot else {
            print("EquipmentComponent: equipItem - trying to equip an item in the wrong slot type.")
            return owner
        }
        
        guard equippedSlots.keys.contains(slot) else {
            print("EquipmentComponent: equipItem - owner does not have this slot type.")
            return owner
        }
        
        guard slotIsEmpty(slot) else {
            print("EquipmentComponent: equipItem - trying to equip an item in an already occupied slot.")
            return owner
        }
        
        var changedEquipmentSlots = equippedSlots
        changedEquipmentSlots[slot] = item
        
        var changedOwner = owner
        changedOwner.variables["EC_equippedSlots"] = changedEquipmentSlots

        return changedOwner
    }
    
    func unequipItem(in slot: EquipmentSlot) -> (updatedEntity: RLEntity, item: RLEntity?) {
        guard let item = equippedSlots[slot] else {
            print("EquipmentComponent: unequipItem - trying to unequip an empty slot.")
            return (owner, nil)
        }
        
        var changedEquipmentSlots = equippedSlots
        changedEquipmentSlots.updateValue(nil, forKey: slot)
        
        var changedOwner = owner
        changedOwner.variables["EC_equippedSlots"] = changedEquipmentSlots
        return (changedOwner, item)
    }
    
    func itemIsEquiped(_ item: RLEntity) -> Bool {
        let equippedItems = equippedSlots.values.compactMap { $0 }
        return equippedItems.contains(where: { $0.id == item.id })
    }
    
    func update() -> RLEntity {
        var changedEntity = owner
        for equipment in equippedSlots {
            if let item = equipment.value {
                changedEntity = item.equipableEffect?.applyEquipmentEffects(to: changedEntity) ?? changedEntity
            }
        }
        return changedEntity
    }
}

extension RLEntity {
    var equipmentComponent: EquipmentComponent? {
        guard variables["EC"] as? Bool ?? false == true,
            let equippedSlots = variables["EC_equippedSlots"] as? [EquipmentSlot: RLEntity?] else {
                return nil
        }
        
        return EquipmentComponent(owner: self, equippedSlots: equippedSlots)
    }
}
