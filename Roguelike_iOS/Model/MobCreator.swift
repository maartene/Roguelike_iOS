//
//  MobCreator.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 04/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct MobCreator {
    
    static func createMob(at location: Coord, on floor: Floor, floorIndex: Int) -> RLEntity {
        guard let newMobType = floor.enemyTypes.randomElement() else {
            fatalError("Floor does not have any enemy types.")
        }
        
        let prototype: RLEntity
        switch newMobType {
        case "Skeleton":
            prototype = RLEntity.skeleton(startPosition: location, floorIndex: floorIndex)
        default:
            prototype = RLEntity(name: "ERROR", floorIndex: floorIndex)
        }
        
        let value = Float.random(in: 0...1.0)
        let rarity: Rarity
        switch value {
        case 0 ..< 0.1:
            rarity = .Rare
        case 0.1 ..< 0.4:
            rarity = .Uncommon
        default:
            rarity = .Common
        }
        
        var newMob = RLEntity(name: prototype.name, color: rarity.color, floorIndex: prototype.floorIndex, startPosition: prototype.position)
        newMob.variables = prototype.variables
        
        newMob = StatsComponent.add(to: newMob)
        
        newMob.variables["SC_currentLevel"] = floor.baseEnemyLevel
        
        newMob.variables["SC_strength"] = rarity.statChange
        newMob.variables["SC_intelligence"] = rarity.statChange
        newMob.variables["SC_dexterity"] = rarity.statChange
        
        var unspentPoints = floor.baseEnemyLevel * 2
        while unspentPoints > 0 {
            newMob.variables["SC_strength"] = 1 + (newMob.statsComponent?.strength ?? 0)
            newMob.variables["SC_intelligence"] = 1 + (newMob.statsComponent?.intelligence ?? 0)
            newMob.variables["SC_dexterity"] = 1 + (newMob.statsComponent?.dexterity ?? 0)
            
            unspentPoints -= 3
        }
        
        newMob = StatsComponent.recalculateStats(for: newMob, maximizingCurrentHealth: true)
        
        newMob.variables.removeValue(forKey: "SC")
        
        return newMob
    }
    
}
