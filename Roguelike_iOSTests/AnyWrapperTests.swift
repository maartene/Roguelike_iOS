//
//  AnyWrapperTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 25/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Roguelike_iOS

class AnyWrapperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrapRLEntity() throws {
        let entity = RLEntity(name: "test entity", floorIndex: 0, startPosition: Coord(15,12))
        let wrappedEntity = try AnyWrapper.wrapperFor(entity)
        
        XCTAssertEqual(entity.id, (wrappedEntity.value as! RLEntity).id)
    }
    
    func testWrapRLEntityArray() throws {
        let entityArray = [RLEntity.apple(startPosition: Coord.zero, floorIndex: 0), RLEntity.lamp(startPosition: Coord.zero, floorIndex: 0)]
        let wrappedArray = try AnyWrapper.wrapperFor(entityArray)
        XCTAssertEqual((wrappedArray.value as! [RLEntity]).count, entityArray.count)
        
    }

}
