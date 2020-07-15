//
//  Coord.swift
//  RogueLike2
//
//  Created by Maarten Engels on 08/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct Coord: Hashable, CustomStringConvertible, Codable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    static func sqr_distance(_ c1: Coord, _ c2: Coord) -> Double {
        let dx = c1.x - c2.x
        let dy = c1.y - c2.y
        return Double(dx * dx + dy * dy)
    }
    
    static var zero: Coord {
        Coord(0,0)
    }
    
    static var up: Coord {
        Coord(0,1)
    }
    
    static var down: Coord {
        Coord(0,-1)
    }
    
    static var left: Coord {
        Coord(-1,0)
    }
    
    static var right: Coord {
        Coord(1,0)
    }
    
    static func +(lhs: Coord, rhs: Coord) -> Coord {
        Coord(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func -(lhs: Coord, rhs: Coord) -> Coord {
        Coord(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    var description: String {
        "(\(x),\(y))"
    }
    
    static func manhattanDistance(coord1: Coord, coord2: Coord) -> Int {
        let vector = coord1 - coord2
        return abs(vector.x) + abs(vector.y)
    }
    
    func manhattanDistance(to coord: Coord) -> Int {
        Coord.manhattanDistance(coord1: self, coord2: coord)
    }
}

