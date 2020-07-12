//
//  VisibilityComponent.swift
//  RogueLike2
//
//  Created by Maarten Engels on 05/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit

struct VisibilityComponent {
    let visionRange: Int
    let owner: RLEntity
    var visibleTiles = Set<Coord>()
    
    fileprivate init(owner: RLEntity, visionRange: Int = 3) {
        self.owner = owner
        self.visionRange = visionRange
    }
    
    static func add(to entity: RLEntity, visionRange: Int) -> RLEntity {
        var changedEntity = entity
        
        changedEntity.variables["VC"] = true
        changedEntity.variables["VC_visionRange"] = visionRange
        changedEntity.variables["VC_visibleTiles"] = Set<Coord>()
        
        return changedEntity
    }
    
    static func update(entity: RLEntity, in world: World) -> [RLEntity] {
        guard entity.variables["VC"] != nil, let visionRange  = entity.variables["VC_visionRange"] as? Int else {
            return [entity]
        }
        
        var visibilityComponent = VisibilityComponent(owner: entity, visionRange: visionRange)
        
        visibilityComponent.refreshVisibility(world: world)
        
        var updatedEntity = entity
        updatedEntity.variables["VC_visibleTiles"] = visibilityComponent.visibleTiles
        return [updatedEntity]
    }
    
    private mutating func refreshVisibility(world: World) {
        visibleTiles.removeAll()
            
        for octant in 0 ..< 8 {
            refreshOctant(world: world, octant: octant);
        }
    }
    
    static func lineOfSight(from coord1: Coord, to coord2: Coord, in world: World) -> Bool {
        let lineCoords = plotLine(from: coord1, to: coord2)
        
        let containsBlocker = lineCoords.contains { coord in
            world.map[coord].blocksLight
        }
        
        return containsBlocker == false
    }
        
    private func transformOctant(row: Int, col: Int, octant: Int) -> Coord {
        switch octant {
        case 0:
            return Coord( col, -row)
        case 1:
            return Coord( row, -col)
        case 2:
            return Coord( row,  col)
        case 3:
            return Coord( col,  row)
        case 4:
            return Coord(-col,  row)
        case 5:
            return Coord(-row,  col)
        case 6:
            return Coord(-row, -col)
        case 7:
            return Coord(-col, -row)
        default:
            return Coord(col, row)
        }
    }
    
    private mutating func refreshOctant(world: World, octant: Int) {
        let line =  ShadowLine()
        var fullShadow = false
        let hero = owner.position
        
        let sqr_visibilityRange = Double(visionRange * visionRange)
        
        for row in 0 ..< visionRange {
            // Stop once we go out of bounds.
            //let pos = hero + transformOctant(row: row, col: 0, octant: octant);
            
            for col in 0 ... row {
                let pos = hero + transformOctant(row: row, col: col, octant: octant)
                if Coord.sqr_distance(pos, hero) <= sqr_visibilityRange {
                    if fullShadow {
                        // world.map[pos.x, pos.y, levelIndex].visible = false
                    } else {
                        let projection = Shadow.projectTile(row: row, col: col)
                        
                        // Set the visibility of this tile.
                        let visible = line.isInShadow(projection) == false
                        //world.map[pos.x, pos.y, levelIndex].visible = visible;
                        if visible {
                            visibleTiles.insert(pos)
                        }
                        
                        // Add any opaque tiles to the shadow map.
                        if visible && world.map[pos].blocksLight == true {
                            line.add(projection);
                            fullShadow = line.isFullShadow
                        }
                    }
                }
            }
        }
    }

    private class ShadowLine {
        var shadows = [Shadow]()
        
        var isFullShadow: Bool {
            return shadows.count == 1 && shadows[0].start == 0 && shadows[0].end == 1
        }
        
        func isInShadow(_ projection: Shadow) -> Bool {
            for shadow in shadows {
                if shadow.contains(other: projection) {
                    return true
                }
            }
            return false
        }
        
        func add(_ shadow: Shadow) {
            // Figure out where to slot the new shadow in the list.
            var index = 0
            while index < shadows.count {
                // Stop when we hit the insertion point.
                if (shadows[index].start >= shadow.start) {
                    break
                }
                index += 1
            }
            
            // The new shadow is going here. See if it overlaps the
            // previous or next.
            var overlappingPrevious: Shadow?
            if index > 0 && shadows[index - 1].end > shadow.start {
                overlappingPrevious = shadows[index - 1];
            }
            
            var overlappingNext: Shadow?
            if index < shadows.count && shadows[index].start < shadow.end {
                overlappingNext = shadows[index];
            }
            
            // Insert and unify with overlapping shadows.
            if overlappingNext != nil {
                if overlappingPrevious != nil {
                    // Overlaps both, so unify one and delete the other.
                    overlappingPrevious!.end = overlappingNext!.end
                    shadows.remove(at: index)
                    } else {
                        // Overlaps the next one, so unify it with that.
                        overlappingNext!.start = shadow.start
                    }
                } else {
                    if overlappingPrevious != nil {
                        // Overlaps the previous one, so unify it with that.
                        overlappingPrevious!.end = shadow.end
                    } else {
                        // Does not overlap anything, so insert.
                        shadows.insert(shadow, at: index)
                }
            }
        }
    }

    private class Shadow {
        var start: Double
        var end: Double
        
        init(start: Double, end: Double) {
            self.start = start
            self.end = end
        }
        
        /// Creates a [Shadow] that corresponds to the projected
        /// silhouette of the tile at [row], [col].
        static func projectTile(row: Int, col: Int) -> Shadow {
            let c = Double(col)
            let r = Double(row)
            let topLeft = c / (r + 2)
            let bottomRight = (c + 1) / (r + 1)
            return Shadow(start: topLeft, end: bottomRight)
        }
        
        /// Returns `true` if [other] is completely covered by this shadow.
        func contains(other: Shadow) -> Bool {
            return start <= other.start && end >= other.end
        }
        
    }
    
    private static func plotLineLow(x0: Int, y0: Int, x1: Int, y1:Int) -> Set<Coord> {
        var result = Set<Coord>()
        
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
            result.insert(Coord(x, Int(y)))
            if D > 0 {
               y = y + yi
               D = D - 2*dx
            }
            D = D + 2*dy
        }
        
        return result
    }

    private static func plotLineHigh(x0: Int, y0: Int, x1: Int, y1: Int) -> Set<Coord> {
        var result = Set<Coord>()
        
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
            result.insert(Coord(Int(x), y))
            if D > 0 {
               x = x + xi
               D = D - 2*dy
            }
            D = D + 2*dx
        }
        return result
    }

    static func plotLine(from c0: Coord, to c1: Coord) -> Set<Coord> {
        let x0 = c0.x
        let y0 = c0.y
        let x1 = c1.x
        let y1 = c1.y
        
        if abs(y1 - y0) < abs(x1 - x0) {
            if x0 > x1 {
                return plotLineLow(x0: x1, y0: y1, x1: x0, y1: y0)
            } else {
                return plotLineLow(x0: x0, y0: y0, x1: x1, y1: y1)
            }
        } else {
            if y0 > y1 {
                return plotLineHigh(x0: x1, y0: y1, x1: x0, y1: y0)
            } else {
                return plotLineHigh(x0: x0, y0: y0, x1: x1, y1: y1)
            }
        }
    }
    
}

extension RLEntity {
    var visibilityComponent: VisibilityComponent? {
        guard (variables["VC"] as? Bool) ?? false == true,
            let visionRange = variables["VC_visionRange"] as? Int,
            let visibleTiles = variables["VC_visibleTiles"] as? Set<Coord> else {
                return nil
        }
        
        var vc = VisibilityComponent(owner: self, visionRange: visionRange)
        vc.visibleTiles = visibleTiles
        return vc
    }
}
