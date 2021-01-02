//
//  MobCreatorTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 05/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Roguelike_iOS

class MobCreatorTests: XCTestCase {
    
    let floor = Floor(baseEnemyLevel: 0, enemyTypes: ["Skeleton"], map: Map())
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateMobs() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var mobCreator = MobCreator(random: PRNG(seed: 123))
        for _ in 0 ..< 20 {
            let mob = mobCreator.createMob(at: Coord.zero, on: floor, floorIndex: 0)
            print(mob)
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
