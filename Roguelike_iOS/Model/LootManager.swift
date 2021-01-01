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
    
    //private var cancellables = Set<AnyCancellable>()
    //var boxedWorld: WorldBox
    
    init(seed: [UInt8] = [0,1,2,3]) {
        let data = Data(seed)
        random = GKARC4RandomSource(seed: data)
        //self.boxedWorld = boxedWorld
    }
    
    /*func registerToDieEvents() {
        EventSystem.main.$lastEvent.sink(receiveCompletion: { complete in
            print("Received complete message: \(complete).")
        }, receiveValue: { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            switch event {
            case .entityDied(let entity):
                let loot = strongSelf.gimmeSomeLoot(at: entity.position, on: entity.floorIndex)
                let createEntityAction = CreateEntityAction(owner: entity, entity: loot)
                strongSelf.boxedWorld.executeAction(createEntityAction)
            default:
                // do nothing
                print("No use for event: \(event)")
            }
            }).store(in: &cancellables)
    }*/
    
    func gimmeSomeLoot(at position: Coord, on floor: Int, minimumRarity: Rarity = .Common ) -> RLEntity {
        var loot: RLEntity
        
        // but what is it?
        // is it an equipment or item?
        if random.nextBool() || minimumRarity != .Common {
            // Equipment!
            let value = random.nextUniform()
            if value <= 0.25 {
                loot = RLEntity.sword(startPosition: position, floorIndex: floor)
            } else if value <= 0.5 {
                loot = RLEntity.helmet(startPosition: position, floorIndex: floor)
            } else if value <= 0.75 {
                loot = RLEntity.shield(startPosition: position, floorIndex: floor)
            } else {
                loot = RLEntity.boots(startPosition: position, floorIndex: floor)
            }
        } else {
            // Item!
            if random.nextBool() {
                loot = RLEntity.apple(startPosition: position, floorIndex: floor)
            } else {
                loot = RLEntity.gold(startPosition: position, floorIndex: floor)
            }
        }
        
        // how good will this equipment be?
        if loot.equipableEffect != nil {
            if minimumRarity != .Common {
                loot = improveItem(loot, rarity: minimumRarity)
            } else {
                let quality = random.nextUniform()
                print("Quality: \(quality)")
                switch quality {
                case 0 ..< 0.1:
                    // Rare
                    loot = improveItem(loot, rarity: .Rare)
                case 0.1 ..< 0.4:
                    // Uncommon
                    loot = improveItem(loot, rarity: .Uncommon)
                default:
                    return loot
                }
            }
        }
        
        return loot
    }
    
    func improveItem(_ item: RLEntity, rarity: Rarity) -> RLEntity {
        let namePrefix = rarity != .Common ? "\(rarity) " : ""
        var improvedItem = RLEntity(name: namePrefix + item.name, color: rarity.color, rarity: rarity, floorIndex: item.floorIndex, spriteName: item.name, startPosition: item.position)
        improvedItem.variables = item.variables
        
        if var changedStats = improvedItem.equipableEffect?.statChange {
            for stat in changedStats {
                changedStats[stat.key] = stat.value + rarity.statChange
            }
            
            improvedItem.variables["EEC_statChange"] = changedStats
        }

        
        return improvedItem
    }
    
}
