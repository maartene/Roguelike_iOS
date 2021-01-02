//
//  LootManagerTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 30/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Roguelike_iOS

class LootManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateLoot() throws {
        let lootManager = LootManager(seed: 987)
        
        for _ in 0 ..< 50 {
            let loot = lootManager.gimmeSomeLoot(at: Coord.zero, on: 0)
            if let eec = loot.equipableEffect {
                print("\(loot.name) \(eec.statChange)")
            }
        }
    }

    func testLootRarity() throws {
        let lootManager = LootManager(seed: 987)
        
        for _ in 0 ..< 10 {
            let loot = lootManager.gimmeSomeLoot(at: Coord.zero, on: 0, minimumRarity: .Uncommon)
            if let eec = loot.equipableEffect {
                print("\(loot.name) \(loot.rarity ?? Rarity.Common) \(eec.statChange)")
                XCTAssertEqual(loot.rarity, Rarity.Uncommon)
            }
        }
        
        for _ in 0 ..< 10 {
            let loot = lootManager.gimmeSomeLoot(at: Coord.zero, on: 0, minimumRarity: .Rare)
            if let eec = loot.equipableEffect {
                print("\(loot.name) \(loot.rarity ?? Rarity.Common) \(eec.statChange)")
                XCTAssertEqual(loot.rarity, Rarity.Rare)
            }
        }
    }

}
