//
//  WorldTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 21/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Roguelike_iOS

class WorldTests: XCTestCase {

    let playerStartPosition = Coord(5,5)
    let mapWidth = 10
    let mapHeight = 10
    var world: World!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        world = World(width: mapWidth, height: mapHeight)
        
        world.floors.append(Floor(baseEnemyLevel: 0, enemyTypes: [], map: Map()))
        
        for y in 0 ..< world.width {
            for x in 0 ..< world.height {
                world.updateMapCell(at: Coord(x,y), on: 0, with: .ground)
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

    func testUpdateEntities() throws {
        // This is an example of a performance test case.
        for _ in 0 ... 1000 {
            let entity = RLEntity.skeleton(startPosition: Coord.zero, floorIndex: (0...9).randomElement()!)
            world.addEntity(entity: entity)
        }
        var pass = 1
        self.measure {
            // Put the code you want to measure the time of here.
            print("Pass: \(pass) Entities on current floor: \(world.entitiesOnCurrentFloor.count) Total entities: \(world.entities.count)")
            world.update()
            pass += 1
        }
    }
    
    func testUpdateEntitiesInclAI() throws {
        // This is an example of a performance test case.
        for _ in 0 ... 1000 {
            let entity = RLEntity.skeleton(startPosition: Coord.zero, floorIndex: (0...19).randomElement()!)
            world.addEntity(entity: entity)
        }
        
        let boxedWorld = WorldBox(world: world)
        
        var pass = 1
        self.measure {
            // Put the code you want to measure the time of here.
            print("Pass: \(pass) Entities on current floor: \(world.entitiesOnCurrentFloor.count) Entities: \(world.entities.count)")
            let waitAction = WaitAction(owner: world.player)
            boxedWorld.executeAction(waitAction)
            pass += 1
        }
    }
    
    func testUpdateCreatesVisibility() throws {
        guard let vc = world.player.visibilityComponent else {
            XCTAssert(false, "Player should have a VisibilityComponent assigned.")
            return
        }
        
        XCTAssertEqual(vc.visibleTiles.count, 0, "No tiles should be visible.")
        
        world.update()
        
        XCTAssertGreaterThan(world.player.visibilityComponent?.visibleTiles.count ?? 0, 0, "Some tiles should be visible.")
    }

}
