//
//  ItemContainerComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 31/12/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct ItemContainerComponent {
    let owner: RLEntity
    let replaceComponent: RLEntity
    let loot: [RLEntity]
    
    fileprivate init(owner: RLEntity, replaceComponent: RLEntity, loot: [RLEntity]) {
        self.owner = owner
        self.replaceComponent = replaceComponent
        self.loot = loot
    }
    
    static func add(to entity: RLEntity, replaceComponent: RLEntity, loot: [RLEntity]) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["ItemCC"] = true
        changedEntity.variables["ItemCC_replaceComponent"] = replaceComponent
        changedEntity.variables["ItemCC_loot"] = loot
        
        return changedEntity
    }
}

extension RLEntity {
    var itemContainerComponent: ItemContainerComponent? {
        guard variables["ItemCC"] as? Bool ?? false == true,
            let replaceComponent = variables["ItemCC_replaceComponent"] as? RLEntity,
            let loot = variables["ItemCC_loot"] as? [RLEntity] else {
            return nil
        }
        
        return ItemContainerComponent(owner: self, replaceComponent: replaceComponent, loot: loot)
    }
}
