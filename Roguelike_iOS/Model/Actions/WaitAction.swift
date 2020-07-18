//
//  WaitAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 14/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct WaitAction: Action {
    let owner: RLEntity
    let title = "Wait"
    let description = "This will let all other entities act."
    
    func execute(in world: World) -> [RLEntity] {
        var updatedWorld = world
        updatedWorld.update()
        return Array(updatedWorld.entities.values)
    }
}
