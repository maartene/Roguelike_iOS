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
    let range: Int
    let target: RLEntity
        
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("ACTION: owner no longer exists in the world.")
            return false
        }
        
        guard actor.healthComponent?.isDead ?? false == false else {
            print("ACTION: owner is dead.")
            return false
        }
        
        guard let target = world.entities[target.id] else {
            print("ACTION: target no longer exists in the world.")
            return false
        }
                
        guard let healthComponent = actor.healthComponent else {
            print("ACTION: target requires an health component.")
            return false
        }
        
        guard target.floorIndex == actor.floorIndex else {
            print("AttackAction - Cannot Execute: target is not on the same floor.")
            return false
        }
        
        let sqrDistance = Coord.sqr_distance(target.position, owner.position)
        guard sqrDistance <= Double(range * range) else {
            print("ACTION: target out of range.")
            return false
        }
                
        guard healthComponent.isDead == false else {
            print("ACTION: cannot attack a dead target.")
            return false
        }
                
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard var actor = world.entities[owner.id] else {
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
        print("Attacked \(damagedTarget.name) \(damagedTarget.id) for \(damage) damage. Remaining hp: \(damagedTarget.healthComponent?.currentHealth ?? 0)/\(damagedTarget.healthComponent?.maxHealth ?? 0)")
        
        // try and add xp to target
        if damagedTarget.healthComponent?.isDead ?? false {
            var xpToAdd = damagedTarget.healthComponent!.xpOnDeath
            if let rarity = damagedTarget.rarity {
                xpToAdd += xpToAdd * rarity.statChange / 2
            }
            xpToAdd += damagedTarget.healthComponent!.xpOnDeath * (damagedTarget.variables["SC_currentLevel"] as? Int ?? 0)
            
            actor = actor.statsComponent?.addXP(xpToAdd) ?? actor
        }
        
        return [damagedTarget, actor]
    }
}
