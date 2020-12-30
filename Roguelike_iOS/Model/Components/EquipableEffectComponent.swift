//
//  EquipableEffectComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 27/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

enum EquipmentSlot: String, CustomStringConvertible, Codable {
    case head
    case body
    case leftArm
    case rightArm
    case legs
    
    var description: String {
        switch self {
        case .head:
            return "Head"
        case .body:
            return "Body"
        case .leftArm:
            return "L. Arm"
        case .rightArm:
            return "R. Arm"
        case .legs:
            return "Legs"
            
        }
    }
}

struct EquipableEffectComponent {
    let owner: RLEntity
    let statChange: [String: Int]
    let occupiesSlot: EquipmentSlot
    
    fileprivate init(owner: RLEntity, statChange: [String: Int], occupiesSlot: EquipmentSlot) {
        self.owner = owner
        self.statChange = statChange
        self.occupiesSlot = occupiesSlot
    }
    
    static func add(to entity: RLEntity, statChange: [String: Int], occupiesSlot: EquipmentSlot) -> RLEntity {
        var changedEntity = entity
        changedEntity.variables["EEC"] = true
        changedEntity.variables["EEC_statChange"] = statChange
        changedEntity.variables["EEC_occupiesSlot"] = occupiesSlot
        return changedEntity
    }
    
    func applyEquipmentEffects(to entity: RLEntity) -> RLEntity {
        var changedEntity = entity
        
        for effect in statChange {
            if changedEntity.variables.keys.contains(effect.key) == false {
                changedEntity.variables[effect.key] = effect.value
            } else if let currentValue = changedEntity.variables[effect.key] as? Int {
                changedEntity.variables[effect.key] = currentValue + effect.value
            } else {
                print("The variable with name \(effect.key) is not an integer in the variable list of entity \(changedEntity.name) \(changedEntity.id)")
            }
        }
        
        return changedEntity
    }
    
    /*func removeEquipmentEffects(to entity: RLEntity) -> RLEntity {
        var changedEntity = entity
        
        for effect in statChange {
            if changedEntity.variables.keys.contains(effect.key) == false {
                changedEntity.variables[effect.key] = effect.value
            } else if let currentValue = changedEntity.variables[effect.key] as? Int {
                changedEntity.variables[effect.key] = currentValue - effect.value
            } else {
                print("The variable with name \(effect.key) is not an integer in the variable list of entity \(changedEntity.name) \(changedEntity.id)")
            }
        }
        
        return changedEntity
    }*/
    
}

extension RLEntity {
    var equipableEffect: EquipableEffectComponent? {
        guard variables["EEC"] as? Bool ?? false == true,
            let statChange = variables["EEC_statChange"] as? [String: Int],
            let occupiesSlot = variables["EEC_occupiesSlot"] as? EquipmentSlot else {
                return nil
        }
        
        return EquipableEffectComponent(owner: self, statChange: statChange, occupiesSlot: occupiesSlot)
    }
}
