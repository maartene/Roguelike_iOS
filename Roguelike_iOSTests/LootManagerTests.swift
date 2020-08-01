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

    let seed: [UInt8] = [42]
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateLoot() throws {
        let boxedWorld = WorldBox(world: World(width: 10, height: 10))
        let lootManager = LootManager(boxedWorld: boxedWorld, seed: seed)
        
        for _ in 0 ..< 50 {
            let loot = lootManager.gimmeSomeLoot(at: Coord.zero)
            if let eec = loot.equipableEffect {
                print("\(loot.name) \(eec.statChange)")
            }
        }
    }

    

}
