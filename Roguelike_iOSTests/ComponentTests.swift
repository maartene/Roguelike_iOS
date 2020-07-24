//
//  ComponentTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 21/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Roguelike_iOS

class ComponentTests: XCTestCase {

    let playerStartPosition = Coord(5,5)
    let mapWidth = 10
    let mapHeight = 10
    var world: World!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        world = World(width: mapWidth, height: mapHeight)
        
        world.map = Map()
        for y in 0 ..< world.width {
            for x in 0 ..< world.height {
                world.map[Coord(x, y)] = .ground
            }
        }
        
        var player = world.player
        player.position = playerStartPosition
        world.replaceEntity(entity: player)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testAddXP() throws {
        guard let sc = world.player.statsComponent else {
            XCTFail("Player should have a StatsComponent assigned.")
            return
        }
        let updatedPlayer = world.player.statsComponent!.addXP(10)
        XCTAssertGreaterThan(updatedPlayer.statsComponent?.currentXP ?? 0, world.player.statsComponent?.currentXP ?? 0)
    }
    
    func testLevelUp() throws {
        guard world.player.statsComponent != nil else {
            XCTFail("Player should have a StatsComponent assigned.")
            return
        }
        
        let updatedPlayer = world.player.statsComponent!.addXP(world.player.statsComponent!.nextLevelXP)
        XCTAssertGreaterThan(updatedPlayer.statsComponent!.currentLevel, world.player.statsComponent!.currentLevel)
        XCTAssertGreaterThan(updatedPlayer.statsComponent!.unspentPoints, world.player.statsComponent!.unspentPoints)
    }
    
    func testSpendingPointsImprovesStats() throws {
        guard world.player.statsComponent != nil else {
            XCTFail("Player should have a StatsComponent assigned.")
            return
        }
        
        var updatedPlayer = world.player
        updatedPlayer.variables["SC_unspentPoints"] = 1
        XCTAssertEqual(updatedPlayer.statsComponent!.unspentPoints, 1)
        
        let statName = StatsComponent.scStats.first!
        let spendingPlayer = updatedPlayer.statsComponent!.spendPoint(on: statName)
        XCTAssertGreaterThan(spendingPlayer.variables[statName] as? Int ?? 0, world.player.variables[statName] as? Int ?? 0)
        XCTAssertEqual(spendingPlayer.statsComponent!.unspentPoints, 0)
    }
}
