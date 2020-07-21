//
//  AttackComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 12/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct AttackComponent {
    let owner: RLEntity
    let range: Int
    let damage: Int
    
    fileprivate init(owner: RLEntity, range: Int, damage: Int) {
        self.owner = owner
        self.range = range
        self.damage = damage
    }
    
    static func add(to entity: RLEntity, range: Int, damage: Int) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["AC"] = true
        changedEntity.variables["AC_range"] = range
        changedEntity.variables["AC_damage"] = damage
        
        return changedEntity
    }
}

extension RLEntity {
    var attackComponent: AttackComponent? {
        guard (variables["AC"] as? Bool) ?? false == true,
            let range = variables["AC_range"] as? Int,
            let damage = variables["AC_damage"] as? Int else {
                return nil
        }
        
        return AttackComponent(owner: self, range: range, damage: damage)
    }
}
