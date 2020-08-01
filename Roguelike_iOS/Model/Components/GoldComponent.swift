//
//  GoldComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 01/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct GoldComponent {
    let owner: RLEntity
    let amount: Int
    
    fileprivate init(owner: RLEntity, amount: Int) {
        self.owner = owner
        self.amount = amount
    }
    
    static func add(to entity: RLEntity, amount: Int) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["GC"] = true
        changedEntity.variables["GC_amount"] = amount
        
        return changedEntity
    }
}

extension RLEntity {
    var goldComponent: GoldComponent? {
        guard variables["GC"] as? Bool ?? false == true,
            let amount = variables["GC_amount"] as? Int else {
                return nil
        }
        
        return GoldComponent(owner: self, amount: amount)
    }
}
