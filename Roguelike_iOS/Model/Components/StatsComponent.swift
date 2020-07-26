//
//  StatsComponent.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 20/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct StatsComponent {
    static let scStats = ["SC_strength", "SC_intelligence", "SC_dexterity"]
    let owner: RLEntity
    var currentXP: Int
    var currentLevel: Int
    var unspentPoints: Int

    var strength: Int
    var intelligence: Int
    var dexterity: Int
    
    var nextLevelXP: Int {
        13 + 12 * currentLevel * currentLevel
    }
    
    var neededXPForNextLevel: Int {
        max(0, nextLevelXP - currentLevel)
    }
    
    fileprivate init(owner: RLEntity, currentXP: Int, currentLevel: Int, unspentPoints: Int, strength: Int, intelligence: Int, dexterity: Int) {
        self.owner = owner
        self.currentXP = currentXP
        self.currentLevel = currentLevel
        self.unspentPoints = unspentPoints
        self.strength = strength
        self.intelligence = intelligence
        self.dexterity = dexterity
    }
    
    static func add(to entity: RLEntity) -> RLEntity {
        var updatedEntity = entity
        
        updatedEntity.variables["SC"] = true
        updatedEntity.variables["SC_currentXP"] = 0
        updatedEntity.variables["SC_currentLevel"] = 1
        updatedEntity.variables["SC_unspentPoints"] = 1
        
        updatedEntity.variables["SC_strength"] = 0
        updatedEntity.variables["SC_intelligence"] = 0
        updatedEntity.variables["SC_dexterity"] = 0
        
        return recalculateStats(for: updatedEntity, maximizingCurrentHealth: true)
    }
    
    func update() -> RLEntity {
        StatsComponent.recalculateStats(for: owner)
    }
    
    private static func recalculateStats(for entity: RLEntity, maximizingCurrentHealth: Bool = false) -> RLEntity {
        var updatedEntity = entity
        
        // attack
        let damage = (entity.variables["SC_strength"] as? Int ?? 0) + (entity.variables["SC_intelligence"] as? Int ?? 0) * 2 + 1
        
        // defense
        let defense = max(0, (entity.variables["SC_strength"] as? Int ?? 0) * 2 + (entity.variables["SC_intelligence"] as? Int ?? 0) - 1)
        
        // maxHealth
        let maxHealth = (entity.variables["SC_dexterity"] as? Int ?? 0) * 3 + 7
        
        updatedEntity.variables["AC_damage"] = damage
        updatedEntity.variables["HC_defense"] = defense
        updatedEntity.variables["HC_maxHealth"] = maxHealth
        
        if maximizingCurrentHealth {
            updatedEntity.variables["HC_currentHealth"] = maxHealth
        }
        
        return updatedEntity
    }
    
    func addXP(_ amount: Int) -> RLEntity {
        var updatedEntity = owner
        
        let newXP = currentXP + amount
        updatedEntity.variables["SC_currentXP"] = newXP
        
        if newXP >= nextLevelXP {
            updatedEntity.variables["SC_currentLevel"] = currentLevel + 1
            updatedEntity.variables["SC_unspentPoints"] = unspentPoints + 1
            EventSystem.main.fireEvent(.levelup(updatedEntity))
        }
        
        return updatedEntity
    }
    
    func spendPoint(on stat: String) -> RLEntity {
        guard StatsComponent.scStats.contains(stat) else {
            print("WARNING: \(stat) is not a support statistic from StatsComponent. Owner not changed.")
            return owner
        }
        
        guard unspentPoints > 0 else {
            print("Not enought unspent points to increase stat \(stat). Owner not changed.")
            return owner
        }
        
        var changedEntity = owner
        if let currentAmount = changedEntity.variables[stat] as? Int {
            changedEntity.variables[stat] = currentAmount + 1
        } else {
            changedEntity.variables[stat] = 1
        }
        
        changedEntity.variables["SC_unspentPoints"] = unspentPoints - 1
    
        return StatsComponent.recalculateStats(for: changedEntity)
    }
}

extension RLEntity {
    var statsComponent: StatsComponent? {
        guard variables["SC"] as? Bool ?? false == true,
            let currentXP = variables["SC_currentXP"] as? Int,
            let currentLevel = variables["SC_currentLevel"] as? Int,
            let unspentPoints = variables["SC_unspentPoints"] as? Int,
            let strength = variables["SC_strength"] as? Int,
            let intelligence = variables["SC_intelligence"] as? Int,
            let dexterity = variables["SC_dexterity"] as? Int else {
            return nil
        }
        return StatsComponent(owner: self, currentXP: currentXP, currentLevel: currentLevel, unspentPoints: unspentPoints, strength: strength, intelligence: intelligence, dexterity: dexterity)
    }
}
