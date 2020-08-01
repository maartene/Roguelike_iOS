//
//  LootManager.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 30/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit
import Combine

final class LootManager {
    
    private let random: GKRandomSource
    
    private var cancellables = Set<AnyCancellable>()
    var boxedWorld: WorldBox
    
    init(boxedWorld: WorldBox, seed: [UInt8] = [0,1,2,3]) {
        let data = Data(seed)
        random = GKARC4RandomSource(seed: data)
        self.boxedWorld = boxedWorld
    }
    
    func registerToDieEvents() {
        EventSystem.main.$lastEvent.sink(receiveCompletion: { complete in
            print("Received complete message: \(complete).")
        }, receiveValue: { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            switch event {
            case .entityDied(let entity):
                let loot = strongSelf.gimmeSomeLoot(at: entity.position)
                let createEntityAction = CreateEntityAction(owner: entity, entity: loot)
                strongSelf.boxedWorld.executeAction(createEntityAction)
            default:
                // do nothing
                print("No use for event: \(event)")
            }
            }).store(in: &cancellables)
    }
    
    func gimmeSomeLoot(at position: Coord) -> RLEntity {
        var loot: RLEntity
        
        // but what is it?
        let value = random.nextUniform()
        switch value {
        case 0 ..< 0.1:
            loot = RLEntity.sword(startPosition: position)
        case 0.1 ..< 0.2:
            loot = RLEntity.helmet(startPosition: position)
        case 0.2 ..< 0.4:
            loot = RLEntity.apple(startPosition: position)
        default:
            loot = RLEntity.gold(startPosition: position)
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
