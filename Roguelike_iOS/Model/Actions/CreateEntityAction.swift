//
//  CreateEntityAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 30/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct CreateEntityAction: Action {
    var owner: RLEntity
    
    let title = "Create entity"
    var description: String {
        "Create an \(entity) in the world."
    }
    let entity: RLEntity
    
    func execute(in world: World) -> [RLEntity] {
        return [entity]
    }
}
