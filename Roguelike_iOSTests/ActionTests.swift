//
//  ActionTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 19/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

import XCTest
@testable import Roguelike_iOS

class ActionTests: XCTestCase {

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
    
    func testExecuteMoveAction() throws {
        XCTAssertEqual(world.player.position, playerStartPosition)
        
        let moveAction = MoveAction(owner: world.player, targetLocation: world.player.position + Coord.left, map: world.map, ignoreVisibility: true)
        world.executeAction(moveAction)
        
        XCTAssertNotEqual(world.player.position, playerStartPosition)
        XCTAssertEqual(world.player.position, playerStartPosition + Coord.left)
    }
    
    func testExecuteAttackAction() throws {
        guard let ac = world.player.attackComponent else {
            XCTAssert(false, "Player should have an attack component set.")
            return
        }
        let skeleton = RLEntity.skeleton(startPosition: playerStartPosition + Coord(ac.range / 2,0))
        
        world.addEntity(entity: skeleton)
        XCTAssertTrue(world.map[skeleton.position].name != "void", "Skeleton should not be in the void.")
        
        let attackAction = AttackAction(owner: world.player, damage: ac.damage, range: 5, target: skeleton)
        
        let skeletonHP = skeleton.healthComponent?.currentHealth ?? 0
        world.executeAction(attackAction)
        
        XCTAssertLessThan(world.entities[skeleton.id]?.healthComponent?.currentHealth ?? 0, skeletonHP, "Skeleton should have less HP by now.")
    }
    
    /*func testUpdateAddsAP() throws {
        guard let actc = world.player.actionComponent else {
            XCTAssert(false, "Player should have an ActionComponent assigned.")
            return
        }
        
        XCTAssertLessThan(actc.currentAP, actc.maxAP)
        let beforeAP = actc.currentAP
        
        world.update()
        
        XCTAssertGreaterThan(world.player.actionComponent?.currentAP ?? -1, beforeAP)
    }*/
}
