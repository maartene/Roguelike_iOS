//
//  World.swift
//  RogueLike2
//
//  Created by Maarten Engels on 04/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit

struct World: Codable {
    var map = Map()
    var entities = [UUID: RLEntity]()
    var allVisibleTiles = Set<Coord>()
    
    var player: RLEntity {
        return entities.values.first(where: {$0.name == "Player"} )!
    }
        
    let width: Int
    let height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        var player = RLEntity(name: "Player", hue: 0.53, saturation: 1, startPosition: Coord(31, 10))
        player = VisibilityComponent.add(to: player, visionRange: 10)
        player = ActionComponent.add(to: player, maxAP: 12, currentAP: 3)
        addEntity(entity: player)
        
        let apple = RLEntity(name: "Apple", hue: 0.36, saturation: 1, startPosition: Coord(31, 12))
        addEntity(entity: apple)
        //createRandomRooms(amount: 10)
    }
    
    mutating func update() {
        for entity in entities.values {
            var updatedEntity = entity
            
            if entity.visibilityComponent != nil {
                replaceEntities(entities: VisibilityComponent.update(entity: entity, in: self))
            }
            
            updatedEntity = entities[updatedEntity.id]!

            replaceEntities(entities: updatedEntity.actionComponent?.update(entity: updatedEntity, in: self) ?? [])
            
            
        }
        
        calculateLighting()
    }
    
    
    
    // calculate light intensity for:
    // 1. affected tiles around player
    // 2. tiles around lights that are visible from player position (LoS check)
    mutating func calculateLighting(){
        for cellCoord in map.coordinates {
            if map[cellCoord].visited && allVisibleTiles.contains(cellCoord) == false {
                let visitedBrightness = map[cellCoord].visitedBrightness
                map[cellCoord].setLight(visitedBrightness)
            } else {
                map[cellCoord].setLight(0)
            }
        }
        
        
        allVisibleTiles.removeAll()
        
        for vc in entities.values.compactMap({ $0.visibilityComponent }) {
            if VisibilityComponent.lineOfSight(from: player.position, to: vc.owner.position, in: self) {
            
                let visibilityRangeSquared = Double(vc.visionRange * vc.visionRange)
                    //vc.refreshVisibility(world: self)
                for coord in vc.visibleTiles {
                    map[coord].visit()
                    allVisibleTiles.insert(coord)
                    let distance: Double = Coord.sqr_distance(vc.owner.position, coord)
                    if distance <= visibilityRangeSquared {
                        let attenuation = 1.0 - (distance / visibilityRangeSquared)
                        let currentLight = map[coord].light
                        let lightValue = max(min(currentLight + attenuation * attenuation, 1), map[coord].visitedBrightness)
                        //print(lightValue)
                        map[coord].setLight(lightValue)
                    }
                }
            }
        }
    }
        
    mutating func moveEntity(entity: RLEntity, newPosition: Coord) {
        if map[newPosition].enterable {
            var changedEntity = entity
            changedEntity.position = newPosition
            replaceEntity(entity: changedEntity)
        }
        
    }
    
    mutating func addEntity(entity: RLEntity) {
        assert(entities[entity.id] == nil, "WARNING: world already contains an entity with id \(entity.id). This entity will be replaced with the one passed.")
        entities[entity.id] = entity
    }
    
    mutating func replaceEntity(entity: RLEntity) {
        assert(entities[entity.id] != nil, "WARNING: world does not contain an entity with id \(entity.id). The entity will be added.")
        entities[entity.id] = entity
    }
    
    mutating func replaceEntities(entities: [RLEntity]) {
        for entity in entities {
            replaceEntity(entity: entity)
        }
    }
    
    func getSpriteNameFor(_ mapCell: MapCell, at coord: Coord) -> String {
        switch mapCell.name {
        case "Double_Wall":
            var suffix = "_"
            suffix += map[coord + Coord(0,1)].name == "Double_Wall" ? "N" : "_"
            suffix += map[coord + Coord(1,0)].name == "Double_Wall" ? "E" : "_"
            suffix += map[coord + Coord(0,-1)].name == "Double_Wall" ? "S" : "_"
            suffix += map[coord + Coord(-1,0)].name == "Double_Wall" ? "W" : "_"
            
            return mapCell.name + suffix
        default:
            return mapCell.name
        }
    }
}

struct MapCell: Codable {
    let name: String
    var hue: Double
    var saturation: Double
    var visitedBrightness: Double
    let maxBrightness: Double
    var light: Double = 0
    var blocksLight: Bool
    var enterable: Bool
    var visited = false
    
    private init(name: String, hue: Double = 0, saturation: Double = 1, visitedBrightness: Double = 0.25, maxBrightness: Double = 1, blocksLight: Bool = false, enterable: Bool = true) {
        self.name = name
        self.hue = hue
        self.saturation = saturation
        self.visitedBrightness = visitedBrightness
        self.maxBrightness = maxBrightness
        self.blocksLight = blocksLight
        self.enterable = enterable
    }
    
    static var ground: MapCell {
        MapCell(name: "DitherSquare_16th", hue: 0.16, saturation: 0, visitedBrightness: 0, maxBrightness: 0.333, blocksLight: false)
    }
    
    static var wall: MapCell {
        //MapCell(name: "Double_Wall", hue: 0.5, saturation: 1, visitedBrightness: 0.5, blocksLight: true, enterable: false)
        MapCell(name: "Brick_Wall", hue: 0.5, saturation: 1, visitedBrightness: 0.5, blocksLight: true, enterable: false)
    }
    
    static var void: MapCell {
        MapCell(name: "void", hue: 0, saturation: 0, blocksLight: false, enterable: false)
    }
    
    mutating func visit() {
        visited = true
    }
    
    mutating func setLight(_ intensity: Double) {
        light = intensity
    }
}

struct Map: Codable {
    private var mapCells = [Coord: MapCell]()
    
    subscript(coord: Coord) -> MapCell {
        get {
            if let cell = mapCells[coord] {
                return cell
            } else {
                return MapCell.void
            }
        }
        
        set(newValue) {
            mapCells[coord] = newValue
        }
    }
    
    var coordinates: [Coord] {
        Array(mapCells.keys)
    }
}