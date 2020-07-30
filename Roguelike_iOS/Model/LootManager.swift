//
//  LootManager.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 30/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit

final class LootManager {
    
    private let random: GKRandomSource
    
    init(seed: [UInt8] = [0,1,2,3]) {
        let data = Data(seed)
        random = GKARC4RandomSource(seed: data)
    }
    
    func gimmeSomeLoot(at position: Coord) -> RLEntity {
        var loot: RLEntity
        
        // but what is it?
        let value = random.nextUniform()
        switch value {
        case 0 ..< 0.3:
            loot = RLEntity.sword(startPosition: position)
        case 0.3 ..< 0.6:
            loot = RLEntity.helmet(startPosition: position)
        default:
            loot = RLEntity.apple(startPosition: position)
        }
         
        
        
        // how good will this equipment be?
        if loot.equipableEffect != nil {
            let quality = random.nextUniform()
            print("Quality: \(quality)")
            switch quality {
            case 0 ..< 0.05:
                // legendary
                loot = improveItem(loot, add: 2)
            case 0.05 ..< 0.2:
                // +1
                loot = improveItem(loot, add: 1)
            default:
                return loot
            }
        }
        
        return loot
    }
    
    func improveItem(_ item: RLEntity, add: Int) -> RLEntity {
        var improvedItem = item
        
        if var changedStats = improvedItem.equipableEffect?.statChange {
            for stat in changedStats {
                changedStats[stat.key] = stat.value + add
            }
            
            improvedItem.variables["EEC_statChange"] = changedStats
        }

        
        
        return improvedItem
    }
    
}
