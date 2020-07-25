//
//  ConsumableEffectComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 25/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct ConsumableEffectComponent {
    let owner: RLEntity
    let statChange: [String: Int]
    
    fileprivate init(owner: RLEntity, statChange: [String: Int]) {
        self.owner = owner
        self.statChange = statChange
    }
    
    static func add(to entity: RLEntity, statChange: [String: Int]) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["CEC"] = true
        changedEntity.variables["CEC_statChange"] = statChange
        
        return changedEntity
    }
    
    func consume(target: RLEntity) -> (consumedItem: RLEntity, updatedTarget: RLEntity) {
        var changedTarget = target
        
        for effect in statChange {
            if changedTarget.variables.keys.contains(effect.key) == false {
                changedTarget.variables[effect.key] = effect.value
            } else if let currentValue = changedTarget.variables[effect.key] as? Int {
                changedTarget.variables[effect.key] = currentValue + effect.value
            } else {
                print("The variable with name \(effect.key) is not an integer in the variable list of entity \(changedTarget.name) \(changedTarget.id)")
            }
        }
        
        // deplete owning entity by removing this component.
        var changedOwner = owner
        changedOwner.variables.removeValue(forKey: "CEC")
        changedOwner.variables.removeValue(forKey: "CEC_statChange")
        
        
        return (changedOwner, changedTarget)
    }
    
    
}

extension RLEntity {
    var consumableEffect: ConsumableEffectComponent? {
        guard self.variables["CEC"] as? Bool ?? false == true,
            let statChange = self.variables["CEC_statChange"] as? [String: Int] else {
                return nil
        }
        
        return ConsumableEffectComponent(owner: self, statChange: statChange)
    }
}
