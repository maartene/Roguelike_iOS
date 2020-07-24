//
//  HealthComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 15/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct HealthComponent {
    let owner: RLEntity
    let maxHealth: Int
    let currentHealth: Int
    let defense: Int
    let xpOnDeath: Int
    
    var isDead: Bool {
        currentHealth <= 0
    }
    
    fileprivate init(owner: RLEntity, maxHealth: Int, currentHealth: Int, defense: Int, xpOnDeath: Int) {
        self.owner = owner
        self.maxHealth = maxHealth
        self.currentHealth = currentHealth
        self.defense = defense
        self.xpOnDeath = xpOnDeath
    }
    
    static func add(to entity: RLEntity, maxHealth: Int, currentHealth: Int, defense: Int, xpOnDeath: Int) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["HC"] = true
        changedEntity.variables["HC_maxHealth"] = maxHealth
        changedEntity.variables["HC_currentHealth"] = min(maxHealth, currentHealth)
        changedEntity.variables["HC_xpOnDeath"] = xpOnDeath
        changedEntity.variables["HC_defense"] = defense
        
        return changedEntity
    }
    
    func takeDamage(amount: Int) -> RLEntity {
        var updatedEntity = owner
        
        updatedEntity.variables["HC_currentHealth"] = currentHealth - max(1,(amount - defense))
        
        return updatedEntity
    }
}

extension RLEntity {
    var healthComponent: HealthComponent? {
        guard (variables["HC"] as? Bool) ?? false == true,
            let maxHealth = variables["HC_maxHealth"] as? Int,
            let currentHealth = variables["HC_currentHealth"] as? Int,
            let defense = variables["HC_defense"] as? Int,
            let xpOnDeath = variables["HC_xpOnDeath"] as? Int else {
                return nil
        }
        
        return HealthComponent(owner: self, maxHealth: maxHealth, currentHealth: currentHealth, defense: defense, xpOnDeath: xpOnDeath)
    }
}
