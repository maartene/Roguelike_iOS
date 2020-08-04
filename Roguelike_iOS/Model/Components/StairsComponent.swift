//
//  StairsComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 03/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct StairsComponent {
    let owner: RLEntity
    let targetFloor: Int
    let targetLocation: Coord
    
    fileprivate init(owner: RLEntity, targetFloor: Int, targetLocation: Coord) {
        self.owner = owner
        self.targetFloor = targetFloor
        self.targetLocation = targetLocation
    }
    
    static func add(to entity: RLEntity, targetFloor: Int, targetLocation: Coord) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["StairsC"] = true
        changedEntity.variables["StairsC_targetFloor"] = targetFloor
        changedEntity.variables["StairsC_targetLocation"] = targetLocation
        
        return changedEntity
    }
}

extension RLEntity {
    var stairsComponent: StairsComponent? {
        guard variables["StairsC"] as? Bool ?? false == true,
            let targetFloor = variables["StairsC_targetFloor"] as? Int,
            let targetLocation = variables["StairsC_targetLocation"] as? Coord else {
            return nil
        }
        
        return StairsComponent(owner: self, targetFloor: targetFloor, targetLocation: targetLocation)
    }
}
