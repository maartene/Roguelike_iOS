//
//  WorldBuilder.swift
//  RogueLike2
//
//  Created by Maarten Engels on 08/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit

struct WorldBuilder {
    
    //static floorEnemies = [0: ["Skeleton"], ]
    
    var world: World
    
    let width: Int
    let height: Int
    
    let random: GKARC4RandomSource
    
    private init(world: World) {
        self.world = world
        self.width = world.width
        self.height = world.height
        
        var seed = Data()
        seed.append(UInt8(0))
        random = GKARC4RandomSource(seed: seed)
    }
    
    static func buildWorld(width: Int, height: Int, floorCount: Int = 1) -> World {
        let world = World(width: width, height: height)
        var builder = WorldBuilder(world: world)
        
        builder.world.floors.removeAll()
        
        for floor in 0 ..< floorCount {
            builder.world.floors.append(Floor(baseEnemyLevel: floor, enemyTypes: ["Skeleton"], map: Map()))
            builder.createRandomRooms(amount: 10, mapLevel: floor)
        }
        
        // create stairs
        for floor in 0 ..< floorCount - 1 {
            builder.createStairs(from: floor, to: floor + 1, oneWay: false)
        }
        
        return builder.world
    }
    
    mutating func createRandomRooms(amount: Int, minSize: Int = 10, maxSize: Int = 20, mapLevel: Int = 0) {
        var rooms = [Room]()
        
        for _ in 0 ..< amount {
            let startY = random.nextInt(upperBound: self.height - maxSize)
            let startX = random.nextInt(upperBound: self.width - maxSize)
            let width = max(random.nextInt(upperBound: maxSize), minSize)
            let height = max(random.nextInt(upperBound: maxSize), minSize)
            
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
            if random.nextBool() {
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
            let numberOfMonsters = random.nextInt(upperBound: 1)
                for _ in 0...numberOfMonsters {
                    let posX = $0.startX + 1 + random.nextInt(upperBound: $0.width - 2)
                    let posY = $0.startY + 1 + random.nextInt(upperBound: $0.height - 2)
                    
                    let value = random.nextUniform()
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
                    
                    newMonster = MobCreator.createMob(at: Coord(posX, posY), on: world.floors[mapLevel], floorIndex: mapLevel)
                    //newMonster = RLEntity.skeleton(startPosition: Coord(posX, posY), floorIndex: mapLevel)
                    
                    //newMonster.levelIndex = mapLevel
                    
                    //newMonster.renderOrder = .ACTOR
                    
                    // only spawn entities on enterable tiles (i.e. not in the wall)
                    if world.floors[mapLevel].map[newMonster.position].enterable {
                        world.addEntity(entity: newMonster)
                    }
                }
            
                let numberOfItems = random.nextInt(upperBound: 1)
                for _ in 0...numberOfItems {
                    let posX = $0.startX + 1 + random.nextInt(upperBound: $0.width - 2)
                    let posY = $0.startY + 1 + random.nextInt(upperBound: $0.height - 2)
                    if world.floors[mapLevel].map[Coord(posX, posY)].enterable {
                        let value = random.nextUniform()
                        //if value < 0.5 {
                            let lamp = RLEntity.lamp(startPosition: Coord(posX,posY), floorIndex: mapLevel)
                            if world.floors[mapLevel].map[lamp.position].enterable {
                                world.addEntity(entity: lamp)
                            }
                        //} else if value < 0.75 {
                           /* let apple = RLEntity.apple(startPosition: Coord(posX, posY))
                            if world.map[apple.position].enterable {
                                world.addEntity(entity: apple)
                            }
                        } else {
                            let sword = RLEntity.sword(startPosition: Coord(posX, posY))
                            if world.map[sword.position].enterable {
                                world.addEntity(entity: sword)
                            }
                        }*/
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
                    world.updateMapCell(at: Coord(x,y), on: mapLevel, with: .wall)
                } else {
                    world.updateMapCell(at: Coord(x,y), on: mapLevel, with: .ground)
                }
            }
        }
    }
    
    mutating func createStairs(from floor1: Int, to floor2: Int, oneWay: Bool = false) {
    
        let enterableCoordsFloor1 = world.floors[floor1].map.enterableTiles
        let enterableCoordsFloor2 = world.floors[floor2].map.enterableTiles
        
        let stairsCoordFloor1 = enterableCoordsFloor1[random.nextInt(upperBound: enterableCoordsFloor1.count)]
        let stairsCoordFloor2 = enterableCoordsFloor2[random.nextInt(upperBound: enterableCoordsFloor2.count)]
        
        
        let name1to2 = floor2 < floor1 ? "Stairs_Up" : "Stairs_Down"
        
        var stairs1to2 = RLEntity(name: name1to2, color: SKColor.yellow, floorIndex: floor1, startPosition: stairsCoordFloor1)
        stairs1to2 = StairsComponent.add(to: stairs1to2, targetFloor: floor2, targetLocation: stairsCoordFloor2)
        world.addEntity(entity: stairs1to2)
        print(stairs1to2)
        
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
