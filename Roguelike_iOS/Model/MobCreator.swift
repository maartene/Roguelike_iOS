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
        
        var newMob: RLEntity
        switch newMobType {
        case "Skeleton":
            newMob = RLEntity.skeleton(startPosition: location, floorIndex: floorIndex)
        default:
            newMob = RLEntity(name: "ERROR", floorIndex: floorIndex)
        }
        
        newMob = StatsComponent.add(to: newMob)
        
        newMob.variables["SC_currentLevel"] = floor.baseEnemyLevel
        
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
