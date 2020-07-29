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
        guard world.player.statsComponent != nil else {
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
    
    func testConsumeItem() throws {
        let apple = RLEntity.apple(startPosition: Coord.zero)
        XCTAssertNotNil(apple.consumableEffect)
        
        var player = RLEntity.player(startPosition: Coord.zero)
        player.variables["HC_currentHealth"] = (player.variables["HC_maxHealth"] as? Int ?? 2) - 1
        XCTAssertNotNil(player.healthComponent)
        
        if let consumeResult = apple.consumableEffect?.consume(target: player) {
            XCTAssertGreaterThan(consumeResult.updatedTarget.healthComponent!.currentHealth, player.healthComponent!.currentHealth)
            XCTAssertNil(consumeResult.consumedItem.consumableEffect)
        }
    }
    
    func testAddItemToInventory() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        
        guard player.inventoryComponent != nil else {
            XCTFail("Player should have an inventory component.")
            return
        }
        
        let apple = RLEntity.apple(startPosition: Coord.zero)
        
        let updatedPlayer = player.inventoryComponent!.addItem(apple)
        
        XCTAssertGreaterThan(updatedPlayer.inventoryComponent!.items.count, player.inventoryComponent!.items.count)
        XCTAssertTrue(updatedPlayer.inventoryComponent!.items.contains(where: { item in
            item.id == apple.id
        }))
    }
    
    func testRemoveItemFromInventory() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        
        guard player.inventoryComponent != nil else {
            XCTFail("Player should have an inventory component.")
            return
        }
        
        let apple = RLEntity.apple(startPosition: Coord.zero)
        
        let updatedPlayer = player.inventoryComponent!.addItem(apple)
        
        XCTAssertGreaterThan(updatedPlayer.inventoryComponent!.items.count, player.inventoryComponent!.items.count)
        XCTAssertTrue(updatedPlayer.inventoryComponent!.items.contains(where: { item in
            item.id == apple.id
        }))
        
        let removingPlayer = player.inventoryComponent!.removeItem(apple)
        XCTAssertLessThan(removingPlayer.inventoryComponent!.items.count, updatedPlayer.inventoryComponent!.items.count)
        XCTAssertFalse(removingPlayer.inventoryComponent!.items.contains(where: { item in
            item.id == apple.id
        }))
    }
    
    func testInventoryFull() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        
        guard player.inventoryComponent != nil else {
            XCTFail("Player should have an inventory component.")
            return
        }
        
        let apple = RLEntity.apple(startPosition: Coord.zero)
        
        var updatedPlayer = player
        for _ in 0 ..< player.inventoryComponent!.size {
            updatedPlayer = updatedPlayer.inventoryComponent!.addItem(apple)
        }
        
        XCTAssertEqual(updatedPlayer.inventoryComponent!.items.count, updatedPlayer.inventoryComponent!.size)
        
        updatedPlayer = updatedPlayer.inventoryComponent!.addItem(apple)
        
        XCTAssertEqual(updatedPlayer.inventoryComponent!.items.count, updatedPlayer.inventoryComponent!.size)
    }
    
    func testEquipSwordIncreasesDamage() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard let eec = sword.equipableEffect else {
            XCTFail("Sword needs an eec attached.")
            return
        }
        
        let equippingPlayer = eec.applyEquipmentEffects(to: player)
        XCTAssertGreaterThan(equippingPlayer.variables["AC_damage"] as? Int ?? 0, player.variables["AC_damage"] as? Int ?? 0)
    }
    
    /*func testEquipSwordResetsDamage() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard let eec = sword.equipableEffect else {
            XCTFail("Sword needs an eec attached.")
            return
        }
        
        let equippingPlayer = eec.applyEquipmentEffects(to: player)
        XCTAssertGreaterThan(equippingPlayer.variables["AC_damage"] as? Int ?? 0, player.variables["AC_damage"] as? Int ?? 0)
        
        let unequippingPlayer = eec.removeEquipmentEffects(to: equippingPlayer)
        
        XCTAssertLessThan(unequippingPlayer.variables["AC_damage"] as? Int ?? 0, equippingPlayer.variables["AC_damage"] as? Int ?? 0)
        XCTAssertEqual(unequippingPlayer.variables["AC_damage"] as? Int ?? 0, player.variables["AC_damage"] as? Int ?? 0)
        
    }*/
    
    func testEquipSwordTest() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard player.equipmentComponent != nil else {
            XCTFail("Player requires an EquipmentComponent.")
            return
        }
        
        XCTAssertTrue(player.equipmentComponent!.slotIsEmpty(.leftArm))
        let equippingPlayer = player.equipmentComponent!.equipItem(sword, in: .leftArm)
        XCTAssertFalse(equippingPlayer.equipmentComponent!.slotIsEmpty(.leftArm))
    }
    
    func testEquipSwordIncreasesDamageTest() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard player.equipmentComponent != nil else {
            XCTFail("Player requires an EquipmentComponent.")
            return
        }
        
        XCTAssertTrue(player.equipmentComponent!.slotIsEmpty(.leftArm))
        var equippingPlayer = player.equipmentComponent!.equipItem(sword, in: .leftArm)
        XCTAssertFalse(equippingPlayer.equipmentComponent!.slotIsEmpty(.leftArm))
        
        equippingPlayer = equippingPlayer.statsComponent?.update() ?? equippingPlayer
        equippingPlayer = equippingPlayer.equipmentComponent?.update() ?? equippingPlayer
        
        XCTAssertGreaterThan(equippingPlayer.variables["AC_damage"] as? Int ?? 0, player.variables["AC_damage"] as? Int ?? 0)
        
    }
    
    func testUnequipSwordTest() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard player.equipmentComponent != nil else {
            XCTFail("Player requires an EquipmentComponent.")
            return
        }
        
        XCTAssertTrue(player.equipmentComponent!.slotIsEmpty(.leftArm))
        let equippingPlayer = player.equipmentComponent!.equipItem(sword, in: .leftArm)
        XCTAssertFalse(equippingPlayer.equipmentComponent!.slotIsEmpty(.leftArm))
        
        if let unequipResult = equippingPlayer.equipmentComponent?.unequipItem(in: .leftArm) {
            XCTAssertTrue(unequipResult.updatedEntity.equipmentComponent?.slotIsEmpty(.leftArm) ?? false)
            XCTAssertEqual(unequipResult.item?.id, sword.id)
        } else {
            XCTFail("Result was nil.")
        }
    }
    
    func testUnEquipSwordDecreasesDamageTest() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard player.equipmentComponent != nil else {
            XCTFail("Player requires an EquipmentComponent.")
            return
        }
        
        XCTAssertTrue(player.equipmentComponent!.slotIsEmpty(.leftArm))
        var equippingPlayer = player.equipmentComponent!.equipItem(sword, in: .leftArm)
        XCTAssertFalse(equippingPlayer.equipmentComponent!.slotIsEmpty(.leftArm))
        
        equippingPlayer = equippingPlayer.statsComponent?.update() ?? equippingPlayer
        equippingPlayer = equippingPlayer.equipmentComponent?.update() ?? equippingPlayer
        
        if let unequipResult = equippingPlayer.equipmentComponent?.unequipItem(in: .leftArm) {
            XCTAssertTrue(unequipResult.updatedEntity.equipmentComponent?.slotIsEmpty(.leftArm) ?? false)
            XCTAssertEqual(unequipResult.item?.id, sword.id)
            
            var unequippingPlayer = unequipResult.updatedEntity.statsComponent?.update() ?? equippingPlayer
            unequippingPlayer = unequippingPlayer.equipmentComponent?.update() ?? equippingPlayer
                        
            XCTAssertLessThan(unequippingPlayer.variables["AC_damage"] as? Int ?? 0, equippingPlayer.variables["AC_damage"] as? Int ?? 0)
            XCTAssertEqual(unequippingPlayer.variables["AC_damage"] as? Int ?? 0, player.variables["AC_damage"] as? Int ?? -1)
        } else {
            XCTFail("Result was nil.")
        }
        
        
    }
    
    func testCannotEquipOccupiedSlot() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        guard player.equipmentComponent != nil else {
            XCTFail("Player requires an EquipmentComponent.")
            return
        }
        
        XCTAssertTrue(player.equipmentComponent!.slotIsEmpty(.leftArm))
        let equippingPlayer = player.equipmentComponent!.equipItem(sword, in: .leftArm)
        XCTAssertFalse(equippingPlayer.equipmentComponent!.slotIsEmpty(.leftArm))
        
        let sword2 = RLEntity.sword(startPosition: Coord.zero)
        let equippingPlayer2 = equippingPlayer.equipmentComponent?.equipItem(sword2, in: .leftArm) ?? equippingPlayer
        
        XCTAssertEqual(equippingPlayer2.equipmentComponent!.equippedSlots[.leftArm, default: sword2]?.id, sword.id)
    }
    
    func testCannotEquipWrongSlotType() throws {
        let player = RLEntity.player(startPosition: Coord.zero)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        
        //print(player.equipmentComponent!.equippedSlots)
        
        guard player.equipmentComponent != nil else {
            XCTFail("Player requires an EquipmentComponent.")
            return
        }
        
        XCTAssertTrue(player.equipmentComponent!.slotIsEmpty(.body))
        let equippingPlayer = player.equipmentComponent!.equipItem(sword, in: .body)
        XCTAssertTrue(equippingPlayer.equipmentComponent!.slotIsEmpty(.body))
    }
}
