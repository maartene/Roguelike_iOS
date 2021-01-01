//
//  World.swift
//  RogueLike2
//
//  Created by Maarten Engels on 04/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit
import Combine

struct Floor: Codable {
    //let floorNumber: Int
    let baseEnemyLevel: Int
    let enemyTypes: [String]
    var map: Map
    let maxEnemyRarity: Rarity
    
    init(baseEnemyLevel: Int, enemyTypes: [String], map: Map, maxEnemyRarity: Rarity = .Legendary) {
        self.baseEnemyLevel = baseEnemyLevel
        self.enemyTypes = enemyTypes
        self.map = map
        self.maxEnemyRarity = maxEnemyRarity
    }
    
    mutating func updateMapCell(at coord: Coord, with cell: MapCell) {
        map[coord] = cell
    }
}

struct World: Codable {
    enum CodingKeys: CodingKey {
        case floors
        case entities
        case width
        case height
    }
    
    var floors = [Floor]()
    
    //var map = Map()
    var entities = [UUID: RLEntity]()
    var allVisibleTiles = Set<Coord>()
    
    var player: RLEntity {
        return entities.values.first(where: {$0.name == "Player"} )!
    }
    
    var currentFloorIndex: Int {
        player.floorIndex
    }
    
    var currentFloor: Floor {
        assert((0 ..< floors.count).contains(currentFloorIndex))
        return floors[currentFloorIndex]
    }
       
    var entitiesOnCurrentFloor: [RLEntity] {
        entities.values.filter { $0.floorIndex == currentFloorIndex }
    }
    
    let width: Int
    let height: Int
    
    let lootManager = LootManager()
        
    init(width: Int, height: Int) {
        self.width = width
        self.height = height

        floors.append(Floor(baseEnemyLevel: 0, enemyTypes: [], map: Map()))
        
        let player = RLEntity.player(startPosition: Coord(31,10), floorIndex: 0)
        addEntity(entity: player)
        
        //let apple = RLEntity.apple(startPosition: Coord(31,12))
        //addEntity(entity: apple)
        //createRandomRooms(amount: 10)
        
        //let skeleton = RLEntity.skeleton(startPosition: Coord(31,15))
        //addEntity(entity: skeleton)
        
        
    }
    
    mutating func executeAction(_ action: Action) {
        print("World: executeAction - \(action)")
        let updatedEntities = action.execute(in: self)
        replaceEntities(entities: updatedEntities)
        update()
    }
    
    mutating func update() {
        let entitiesOnFloor = entities.values.filter({ $0.floorIndex == currentFloorIndex })
        for entity in entitiesOnFloor {
            var updatedEntity = entities[entity.id] ?? entity
            
            updatedEntity = updatedEntity.visibilityComponent?.update(in: self) ?? updatedEntity
            updatedEntity = updatedEntity.healthComponent?.update() ?? updatedEntity
            updatedEntity = updatedEntity.statsComponent?.update() ?? updatedEntity
            updatedEntity = updatedEntity.equipmentComponent?.update() ?? updatedEntity
            
            replaceEntity(entity: updatedEntity)
        }
        
        _ = pruneEntities()
        
        calculateLighting()
    }
    
    mutating func updateMapCell(at coord: Coord, on floor: Int, with cell: MapCell) {
        assert((0 ..< floors.count).contains(floor))
        
        var changedFloor = floors[floor]
        changedFloor.updateMapCell(at: coord, with: cell)
        floors[floor] = changedFloor
    }
    
    // calculate light intensity for:
    // 1. affected tiles around player
    // 2. tiles around lights that are visible from player position (LoS check)
    mutating func calculateLighting(){
        let currentFloorIndex = self.currentFloorIndex
        var map = currentFloor.map
        for cellCoord in map.coordinates {
            if map[cellCoord].visited && allVisibleTiles.contains(cellCoord) == false {
                let visitedBrightness = map[cellCoord].visitedBrightness
                let litCell = map[cellCoord].setLight(visitedBrightness)
                updateMapCell(at: cellCoord, on: currentFloorIndex, with: litCell)
            } else {
                updateMapCell(at: cellCoord, on: currentFloorIndex, with: map[cellCoord].setLight(0))
            }
        }
        
        
        allVisibleTiles.removeAll()
        
        for vc in entitiesOnCurrentFloor.compactMap({ $0.visibilityComponent }) {
            map = currentFloor.map
            if VisibilityComponent.lineOfSight(from: player.position, to: vc.owner.position, in: self) && vc.addsLight {
            
                let visibilityRangeSquared = Double(vc.visionRange * vc.visionRange)
                    //vc.refreshVisibility(world: self)
                for coord in vc.visibleTiles {
                    let visitedCell = map[coord].visit()
                    
                    updateMapCell(at: coord, on: currentFloorIndex, with: visitedCell)
                    //map[coord].visit()
                    allVisibleTiles.insert(coord)
                    let distance: Double = Coord.sqr_distance(vc.owner.position, coord)
                    if distance <= visibilityRangeSquared {
                        let attenuation = 1.0 - (distance / visibilityRangeSquared)
                        let currentLight = map[coord].light
                        let lightValue = max(min(currentLight + attenuation * attenuation, 1), map[coord].visitedBrightness)
                        //print(lightValue)
                        updateMapCell(at: coord, on: currentFloorIndex, with: visitedCell.setLight(lightValue))
                    }
                }
            }
        }
    }
        
/*    mutating func moveEntity(entity: RLEntity, newPosition: Coord) {
        if map[newPosition].enterable {
            var changedEntity = entity
            changedEntity.position = newPosition
            replaceEntity(entity: changedEntity)
        }
        
    }*/
    
    mutating func addEntity(entity: RLEntity) {
        assert(entities[entity.id] == nil, "WARNING: world already contains an entity with id \(entity.id). This entity will be replaced with the one passed.")
        entities[entity.id] = entity
    }
    
    mutating func replaceEntity(entity: RLEntity) {
        //assert(entities[entity.id] != nil, "WARNING: world does not contain an entity with id \(entity.id). The entity will be added.")
        entities[entity.id] = entity
    }
    
    mutating func pruneEntities() -> [RLEntity] {
        let entitiesToRemove = entitiesOnCurrentFloor.filter {
            $0.healthComponent?.isDead ?? false ||
            $0.variables["SHOULD_REMOVE"] as? Bool ?? false == true
        }
        for entityID in entitiesToRemove.map({$0.id}) {
            if entityID == player.id {
                addEntity(entity: RLEntity.playerRemains(startPosition: player.position, floorIndex: player.floorIndex))
            }
            entities.removeValue(forKey: entityID)
        }
        return entitiesToRemove
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
            suffix += currentFloor.map[coord + Coord(0,1)].name == "Double_Wall" ? "N" : "_"
            suffix += currentFloor.map[coord + Coord(1,0)].name == "Double_Wall" ? "E" : "_"
            suffix += currentFloor.map[coord + Coord(0,-1)].name == "Double_Wall" ? "S" : "_"
            suffix += currentFloor.map[coord + Coord(-1,0)].name == "Double_Wall" ? "W" : "_"
            
            return mapCell.name + suffix
        default:
            return mapCell.name
        }
    }
    
    mutating func processEvent(_ event: RLEvent) {
        switch event {
        case .entityDied(let entity):
            let loot = lootManager.gimmeSomeLoot(at: entity.position, on: entity.floorIndex)
            addEntity(entity: loot)
        default:
            return
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
    
    func visit() -> MapCell{
        var visitedCell = self
        visitedCell.visited = true
        return visitedCell
    }
    
    func setLight(_ intensity: Double) -> MapCell {
        var changedCell = self
        changedCell.light = intensity
        return changedCell
    }
    
    var lightedBrightness: CGFloat {
        CGFloat(light * maxBrightness)
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
    
    var enterableTiles: [Coord] {
        Array(mapCells.filter({cell in cell.value.enterable}).keys)
    }
}
