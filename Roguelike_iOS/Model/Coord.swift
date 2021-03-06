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
    
    static func *(lhs: Coord, rhs: Int) -> Coord {
        Coord(lhs.x * rhs, lhs.y * rhs)
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
    
    static func getNeighbourCoordinates(for coord: Coord) -> Set<Coord> {
        var result = Set<Coord>()
        result.insert(coord + Coord.up)
        result.insert(coord + Coord.down)
        result.insert(coord + Coord.left)
        result.insert(coord + Coord.right)
        return result
    }
    
    var neighbourCoordinates: Set<Coord> {
        Coord.getNeighbourCoordinates(for: self)
    }
    
    static func getDiagonalNeighbourCoordinates(for coord: Coord) -> Set<Coord> {
        var result = Set<Coord>()
        result.insert(coord + Coord(1,1))
        result.insert(coord + Coord(-1,-1))
        result.insert(coord + Coord(-1,1))
        result.insert(coord + Coord(1,-1))
        return result
    }
    
    var diagonalNeighbourCoordinates: Set<Coord> {  Coord.getDiagonalNeighbourCoordinates(for: self)
    }
    
    private static func plotLineLow(x0: Int, y0: Int, x1: Int, y1:Int) -> [Coord] {
        var result = [Coord]()
        
        let dx = Double(x1) - Double(x0)
        var dy = Double(y1) - Double(y0)
        var yi = 1.0

        if dy < 0 {
            yi = -1
            dy = -dy
        }
        
        var D: Double = 2*dy - dx
        var y = Double(y0)

        for x in x0 ... x1 {
            result.append(Coord(x, Int(y)))
            if D > 0 {
               y = y + yi
               D = D - 2*dx
            }
            D = D + 2*dy
        }
        
        return result
    }

    private static func plotLineHigh(x0: Int, y0: Int, x1: Int, y1: Int) -> [Coord] {
        var result = [Coord]()
        
        var dx = Double(x1) - Double(x0)
        let dy = Double(y1) - Double(y0)
        
        var xi = 1.0
        
        if dx < 0 {
            xi = -1
            dx = -dx
        }
        
        var D: Double = 2*dx - dy
        var x = Double(x0)

        for y in y0 ... y1 {
            result.append(Coord(Int(x), y))
            if D > 0 {
               x = x + xi
               D = D - 2*dy
            }
            D = D + 2*dx
        }
        return result
    }

    static func plotLine(from c0: Coord, to c1: Coord) -> [Coord] {
        let x0 = c0.x
        let y0 = c0.y
        let x1 = c1.x
        let y1 = c1.y
        
        if abs(y1 - y0) < abs(x1 - x0) {
            if x0 > x1 {
                return plotLineLow(x0: x1, y0: y1, x1: x0, y1: y0).reversed()
            } else {
                return plotLineLow(x0: x0, y0: y0, x1: x1, y1: y1)
            }
        } else {
            if y0 > y1 {
                return plotLineHigh(x0: x1, y0: y1, x1: x0, y1: y0).reversed()
            } else {
                return plotLineHigh(x0: x0, y0: y0, x1: x1, y1: y1)
            }
        }
    }
    
    // Function to put pixels
    // at subsequence points
    private static func drawCircle(xc: Int, yc: Int, x: Int, y: Int) -> Set<Coord>
    {
        var result = Set<Coord>()
        result.insert(Coord(xc+x, yc+y))
        result.insert(Coord(xc-x, yc+y))
        result.insert(Coord(xc+x, yc-y))
        result.insert(Coord(xc-x, yc-y))
        
        result.insert(Coord(xc+y, yc+x))
        result.insert(Coord(xc-y, yc+x))
        result.insert(Coord(xc+y, yc-x))
        result.insert(Coord(xc-y, yc-x))
        
        return result
    }
    
    // Function for circle-generation
    // using Bresenham's algorithm
    static func circleBres(center: Coord, radius r: Int) -> Set<Coord>
    {
        let xc = center.x
        let yc = center.y
        
        var result = Set<Coord>()
        
        var x = 0
        var y = r
        var d = 3 - 2 * r
        
        result = result.union(drawCircle(xc: xc, yc: yc, x: x, y: y))
        
        while (y >= x)
        {
            // for each pixel we will
            // draw all eight pixels
              
            x += 1
      
            // check for decision parameter
            // and correspondingly
            // update d, x, y
            if (d > 0)
            {
                y -= 1
                d = d + 4 * (x - y) + 10;
            } else {
                d = d + 4 * x + 6;
            }
            result = result.union(drawCircle(xc: xc, yc: yc, x: x, y: y))
        }
        
        //print("Circle coordinates: \(result)")
        return result
    }
}

