//
//  SpendStatPointAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 22/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct SpendStatPointAction: Action {
    let owner: RLEntity
    let title = "Spend point"
    let stat: String
    let description = "Spend a stat point to improve a random stat."
    
    func canExecute(in world: World) -> Bool {
        guard world.entities[owner.id] != nil else {
            print("ACTION: owner \(owner.name) \(owner.id) no longer exists in the world.")
            return false
        }
        
        guard StatsComponent.scStats.contains(stat) else {
            print("ACTION: unknown stat \(stat)")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard let actor = world.entities[owner.id] else {
            print("NO EFFECT: owner \(owner.name) \(owner.id) no longer exists in the world.")
            return []
        }
        
        guard canExecute(in: world) else {
            print("NO EFFECT: cannot execute action \(title).")
            return []
        }
        
        let changedEntity = actor.statsComponent?.spendPoint(on: stat) ?? actor
        
        return [changedEntity]
    }
    
}
