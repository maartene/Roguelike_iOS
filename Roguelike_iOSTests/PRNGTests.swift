//
//  PRNGTests.swift
//  Roguelike_iOSTests
//
//  Created by Maarten Engels on 04/01/2021.
//  Copyright © 2021 thedreamweb. All rights reserved.
//

import XCTest
@testable import Roguelike_iOS

class PRNGTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFairness() throws {
        var rng = PRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
        
        let flips = 1_000_000
        var heads = 0
        for _ in 0 ..< flips {
            if Bool.random(using: &rng) {
                heads += 1
            }
        }
        
        let p = 0.5
        let μ = Double(flips) * p
        let ɑ = sqrt(Double(flips) * p * (1.0 - p))
        
        print("After \(flips) coin flips, we got \(heads). Expected: \(μ) Standard deviation: \(ɑ)")
        XCTAssert( ( μ - 2*ɑ ... μ + 2*ɑ).contains(Double(heads)) )
    }
    
    func testMinCycles() throws {
        var rng = PRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
        
        let targetMinCycles = 1_000_000
        var results = Set<UInt64>()
        
        var collision = false
        var i = 0;
        while i < targetMinCycles && collision == false {
            let result = rng.next()
            if results.contains(result) {
                collision = true
            }
            results.insert(result)
            i += 1
        }
        
        XCTAssertEqual(results.count, targetMinCycles)
        
    }
    
    func testNotSameResult() throws {
        for x: UInt64 in 0 ... 1_000_000 {
            XCTAssertNotEqual(x, Squirrel3(x))
        }
    }
    
    func testNoCollisions() throws {
        let targetMinCycles = 1_000_000
        var results = Set<UInt64>()
        
        var collision = false
        var i: UInt64 = 0;
        while i < targetMinCycles && collision == false {
            let result = Squirrel3(i)
            if results.contains(result) {
                collision = true
            }
            results.insert(result)
            i += 1
        }
        
        XCTAssertEqual(results.count, targetMinCycles)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        var pass = 0
        self.measure {
            pass += 1
            var rng = PRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
            // Put the code you want to measure the time of here.
            // Generate a lot of bools
            
            var heads = 0
            for _ in 0 ..< 1_000_000 {
                if Bool.random(using: &rng) {
                    heads += 1
                }
            }
            
            print("Pass: \(pass) - number of heads: \(heads).")
            
        }
    }

}
