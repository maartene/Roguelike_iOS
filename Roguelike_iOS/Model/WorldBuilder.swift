//
//  WorldBuilder.swift
//  RogueLike2
//
//  Created by Maarten Engels on 08/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct WorldBuilder {
    
    //static floorEnemies = [0: ["Skeleton"], ]
    
    var world: World
    
    let width: Int
    let height: Int
    
    var random: PRNG
    var mobCreator: MobCreator
    
    var playerStartPosition = Coord.zero
    
    private init(world: World, seed: UInt64 = 0) {
        self.world = world
        self.width = world.width
        self.height = world.height
        
        random = PRNG(seed: seed)
        mobCreator = MobCreator()
    }
    
    static func buildWorld(width: Int, height: Int, floorCount: Int = 1) -> World {
        let world = World(width: width, height: height)
        var builder = WorldBuilder(world: world)
        
        builder.world.floors.removeAll()
        
        for floor in 0 ..< floorCount {
            let maxRarity: Rarity
            switch floor {
            case 0:
                maxRarity = .Common
            case 1:
                maxRarity = .Uncommon
            case 2:
                maxRarity = .Rare
            case 3:
                maxRarity = .Legendary
            default:
                maxRarity = .Unique
            }
            
            builder.world.floors.append(Floor(baseEnemyLevel: floor, enemyTypes: ["Skeleton"], map: Map(), maxEnemyRarity: maxRarity))
            builder.createRandomRooms(amount: 10, mapLevel: floor)
        }
        
        // create stairs
        for floor in 0 ..< floorCount - 1 {
            builder.createStairs(from: floor, to: floor + 1, oneWay: false)
        }
        
        var teleportedPlayer = builder.world.player
        teleportedPlayer.position = builder.playerStartPosition
        builder.world.replaceEntity(entity: teleportedPlayer)
        
        return builder.world
    }
    
    mutating func createRandomRooms(amount: Int, minSize: Int = 10, maxSize: Int = 20, mapLevel: Int = 0) {
        var rooms = [Room]()
        
        let room0 = Room(startX: width / 2, startY: height / 2, width: 15, height: 10)
        playerStartPosition = Coord(1 + width / 2, 1 + height / 2)
        rooms.append(room0)
        
        for _ in 1 ..< amount {
            let startY = Int.random(in: 0 ..< self.height - maxSize, using: &random)
            let startX = Int.random(in: 0 ..< self.width - maxSize, using: &random)
            let width = max(Int.random(in: 0 ..< maxSize, using: &random), minSize)
            let height = max(Int.random(in: 0 ..< maxSize, using: &random), minSize)
            
            rooms.append(Room(startX: startX, startY: startY, width: width, height: height))
        }
        
        //moveEntity(id: player.id, newPosition: Coord(rooms[0].centerX, rooms[0].centerY))
        
        // render rooms to map
        rooms.forEach {
            createRoom(mapLevel: mapLevel, startX: $0.startX, startY: $0.startY, width: $0.width, height: $0.height)
        }
        
        // connect rooms
        //var roomsWithoutConnections = Array(rooms)
        
        for i in 0 ..< rooms.count - 1
        {
            let room = rooms[i]
            let otherRoom = rooms[i+1]
            
            //print("L\(mapLevel): connecting room \(room) to \(otherRoom)")
            
            let fromX = min(room.centerX, otherRoom.centerX)
            let toX = max(room.centerX, otherRoom.centerX)
            let fromY = min(room.centerY, otherRoom.centerY)
            let toY = max(room.centerY, otherRoom.centerY)
            
            // flip a coin
            if Bool.random(using: &random) {
                // first horizontal, then vertical
                createHorizontalTunnel(from: (fromX, room.centerY), to: toX, on: mapLevel)
                createVerticalTunnel(from: (otherRoom.centerX, fromY), to: toY, on: mapLevel)
            } else {
                // first vertical, then horizontal
                createVerticalTunnel(from: (room.centerX, fromY), to: toY, on: mapLevel)
                createHorizontalTunnel(from: (fromX, otherRoom.centerY), to: toX, on: mapLevel)
            }
            
            
            /*roomsWithoutConnections.removeLast()
            if roomsWithoutConnections.count > 0 {
                roomsWithoutConnections.removeFirst()
            }*/
        }
        
        // add entities to rooms
        rooms.forEach {
            let numberOfMonsters = Int.random(in: 0 ..< 1, using: &random)
                for _ in 0...numberOfMonsters {
                    let posX = $0.startX + 1 + Int.random(in: 0 ..< $0.width - 2, using: &random)
                    let posY = $0.startY + 1 + Int.random(in: 0 ..< $0.height - 2, using: &random)
                    
                    let value = Double.random(in: 0...1, using: &random)
                    var newMonster: RLEntity
                    /*if value < 0.5 {
                        newMonster = MonsterPrototypes.GetCloneOfPrototype("Rat", world: self)
                    } else if value < 0.75 {
                        newMonster = MonsterPrototypes.GetCloneOfPrototype("Skeleton", world: self)
                    } else if value < 0.9 {
                        newMonster = MonsterPrototypes.GetCloneOfPrototype("Goblin", world: self)
                    } else {
                        newMonster = MonsterPrototypes.GetCloneOfPrototype("Troll", world: self)
                    }*/
                    
                    newMonster = mobCreator.createMob(at: Coord(posX, posY), on: world.floors[mapLevel], floorIndex: mapLevel)
                    //newMonster = RLEntity.skeleton(startPosition: Coord(posX, posY), floorIndex: mapLevel)
                    
                    //newMonster.levelIndex = mapLevel
                    
                    //newMonster.renderOrder = .ACTOR
                    
                    // only spawn entities on enterable tiles (i.e. not in the wall)
                    if world.floors[mapLevel].map[newMonster.position].enterable {
                        world.addEntity(entity: newMonster)
                    }
                }
            
            let numberOfItems = Int.random(in: 0...1, using: &random)
                for _ in 0...numberOfItems {
                    let posX = $0.startX + 1 + Int.random(in: 0 ..< $0.width - 2, using: &random)
                    let posY = $0.startY + 1 + Int.random(in: 0 ..< $0.height - 2, using: &random)
                    if world.floors[mapLevel].map[Coord(posX, posY)].enterable {
                        let value = Double.random(in: 0...1, using: &random)
                        if value < 0.5 {
                            let lamp = RLEntity.lamp(startPosition: Coord(posX,posY), floorIndex: mapLevel)
                            if world.floors[mapLevel].map[lamp.position].enterable {
                                world.addEntity(entity: lamp)
                            }
                        } else if value < 0.75 {
                            let apple = RLEntity.apple(startPosition: Coord(posX, posY), floorIndex: mapLevel)
                            if world.floors[mapLevel].map[apple.position].enterable {
                                world.addEntity(entity: apple)
                            }
                        } else {
                            let chest = RLEntity.chest(startPosition: Coord(posX, posY), floorIndex: mapLevel)
                            if world.floors[mapLevel].map[chest.position].enterable {
                                world.addEntity(entity: chest)
                            }
                        }
                    }
                }
            }
        
        
        
        //allRooms[mapLevel] = rooms
    }
    
    mutating func createHorizontalTunnel(from: (x:Int, y:Int), to endX:Int, on floor: Int) {
        for x in from.x ... endX {
            let downTile = world.floors[floor].map[Coord(x, from.y - 1)].enterable == false ? MapCell.wall : MapCell.ground
            world.updateMapCell(at: Coord(x, from.y - 1), on: floor, with: downTile)
            world.updateMapCell(at: Coord(x, from.y), on: floor, with: .ground)
            let upTile = world.floors[floor].map[Coord(x, from.y + 1)].enterable == false ? MapCell.wall : MapCell.ground
            world.updateMapCell(at: Coord(x, from.y + 1), on: floor, with: upTile)
        }
    }
    
    mutating func createVerticalTunnel(from: (x: Int, y: Int), to endY: Int, on floor: Int) {
        for y in from.y ... endY {
            let leftTile = world.floors[floor].map[Coord(from.x - 1, y)].enterable == false ? MapCell.wall : MapCell.ground
            world.updateMapCell(at: Coord(from.x - 1, y), on: floor, with: leftTile)
            world.updateMapCell(at: Coord(from.x, y), on: floor, with: .ground)
            let rightTile = world.floors[floor].map[Coord(from.x + 1, y)].enterable == false ? MapCell.wall : MapCell.ground
            world.updateMapCell(at: Coord(from.x + 1, y), on: floor, with: rightTile)
        }
    }
    
    
    mutating func createRoom(mapLevel: Int, startX: Int, startY: Int, width: Int, height: Int) {
        if startY + height >= self.height || startX + width >= self.width {
            return
        }
        
        //print("L\(mapLevel): Creating room at position: (\(startX), \(startY)) with width: \(width) height: \(height)")
        
        for y in startY ..< startY + height {
            for x in startX ..< startX + width {
                if x == startX || x == (startX + width - 1) || y == startY || y == (startY + height - 1) {
                    if world.floors[mapLevel].map[Coord(x,y)].enterable == false {  world.updateMapCell(at: Coord(x,y), on: mapLevel, with: .wall)
                    }
                } else {
                    world.updateMapCell(at: Coord(x,y), on: mapLevel, with: .ground)
                }
            }
        }
    }
    
    mutating func createStairs(from floor1: Int, to floor2: Int, oneWay: Bool = false) {
        // the sequence in which these returns is NOT deterministic
        let enterableCoordsFloor1 = world.floors[floor1].map.enterableTiles
        let enterableCoordsFloor2 = world.floors[floor2].map.enterableTiles
        
        // so we need some way of making them deterministic
        // here we'll assign an "index" to every coordinate value
        let sortedEnterableCoordsFloor1 = enterableCoordsFloor1.sorted(by: { coord1, coord2 in
            let coord1Value = coord1.y * width + coord1.x
            let coord2Value = coord2.y * width + coord2.x
            return coord1Value > coord2Value
        })
        let sortedEnterableCoordsFloor2 = enterableCoordsFloor2.sorted(by: { coord1, coord2 in
            let coord1Value = coord1.y * width + coord1.x
            let coord2Value = coord2.y * width + coord2.x
            return coord1Value > coord2Value
        })
        
        let index1 = Int.random(in: 0..<enterableCoordsFloor1.count, using: &random)
        let index2 = Int.random(in: 0..<enterableCoordsFloor2.count, using: &random)
        
        let stairsCoordFloor1 = sortedEnterableCoordsFloor1[index1]
        let stairsCoordFloor2 = sortedEnterableCoordsFloor2[index2]
        
        
        let name1to2 = floor2 < floor1 ? "Stairs_Up" : "Stairs_Down"
        
        var stairs1to2 = RLEntity(name: name1to2, color: SKColor.yellow, floorIndex: floor1, startPosition: stairsCoordFloor1)
        stairs1to2 = StairsComponent.add(to: stairs1to2, targetFloor: floor2, targetLocation: stairsCoordFloor2)
        world.addEntity(entity: stairs1to2)
        //print(stairs1to2)
        
        if oneWay == false {
            let name2to1 = floor1 < floor2 ? "Stairs_Up" : "Stairs_Down"
            var stairs2to1 = RLEntity(name: name2to1, color: SKColor.yellow, floorIndex: floor2, startPosition: stairsCoordFloor2)
            stairs2to1 = StairsComponent.add(to: stairs2to1, targetFloor: floor1, targetLocation: stairsCoordFloor1)
            world.addEntity(entity: stairs2to1)
        }
        
    }
}

struct Room {
    let startX: Int
    let startY: Int
    let width: Int
    let height: Int
    
    var centerX: Int {
        get {
            return startX + width / 2
        }
    }
    
    var centerY: Int {
        get {
            return startY + height / 2
        }
    }
}
