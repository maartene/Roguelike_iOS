//
//  AttackAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 15/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct AttackAction: Action {
    let owner: RLEntity
    let title = "Attack"
    let description = "Attack a target with non-elemental damage."
    let damage: Int
    let target: RLEntity
    
    func canExecute(in world: World) -> Bool {
        let actor = world.entities[owner.id] ?? owner
        
        guard let target = world.entities[target.id] else {
            print("ACTION: target no longer exists in the world.")
            return false
        }
        
        guard let healthComponent = target.healthComponent else {
            print("ACTION: can only attack a target with a health component.")
            return false
        }
        
        guard healthComponent.isDead == false else {
            print("ACTION: cannot attack a dead target.")
            return false
        }
        
        guard actor.actionComponent?.currentAP ?? 1 > 0 else {
            print("ACTION: entity \(actor) does not have enough action points to execute action \(self).")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard let actor = world.entities[owner.id] else {
            print("NO EFFECT: owner no longer exists in the world.")
            return []
        }
        guard canExecute(in: world) else {
            print("NO EFFECT: cannot perform attack action \(self).")
            return []
        }
        
        guard let updatedTarget = world.entities[target.id] else {
            print("NO EFFECT: target no longer exists in the world.")
            return []
        }
        
        let damagedTarget = updatedTarget.healthComponent?.takeDamage(amount: damage) ?? target
        print("Attacked \(damagedTarget) for \(damage) damage. Remaining hp: \(damagedTarget.healthComponent?.currentHealth ?? 0)/\(damagedTarget.healthComponent?.maxHealth ?? 0)")
        return [damagedTarget, actor]
    }
}
