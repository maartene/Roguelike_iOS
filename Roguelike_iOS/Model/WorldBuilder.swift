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
    
    var world: World
    
    let width: Int
    let height: Int
    
    private init(world: World) {
        self.world = world
        self.width = world.width
        self.height = world.height
    }
    
    static func buildWorld(width: Int, height: Int) -> World {
        let world = World(width: width, height: height)
        var builder = WorldBuilder(world: world)
        
        builder.createRandomRooms(amount: 10)
        return builder.world
    }
    
    mutating func createRandomRooms(amount: Int, minSize: Int = 10, maxSize: Int = 20, mapLevel: Int = 0) {
        var seed = Data()
        seed.append(UInt8(mapLevel))
        let random = GKARC4RandomSource(seed: seed)
        
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
        var roomsWithoutConnections = Array(rooms)
        
        while roomsWithoutConnections.count > 0
        {
            let room = roomsWithoutConnections.last!
            let otherRoom = roomsWithoutConnections.first!
            
            let fromX = min(room.centerX, otherRoom.centerX)
            let toX = max(room.centerX, otherRoom.centerX)
            let fromY = min(room.centerY, otherRoom.centerY)
            let toY = max(room.centerY, otherRoom.centerY)
            
            // flip a coin
            if random.nextBool() {
                // first horizontal, then vertical
                createHorizontalTunnel(from: (fromX, room.centerY), to: toX)
                createVerticalTunnel(from: (otherRoom.centerX, fromY), to: toY)
            } else {
                // first vertical, then horizontal
                createVerticalTunnel(from: (room.centerX, fromY), to: toY)
                createHorizontalTunnel(from: (fromX, otherRoom.centerY), to: toX)
            }
            
            
            roomsWithoutConnections.removeLast()
            if roomsWithoutConnections.count > 0 {
                roomsWithoutConnections.removeFirst()
            }
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
                    
                    newMonster = RLEntity.skeleton(startPosition: Coord(posX, posY))
                    
                    //newMonster.levelIndex = mapLevel
                    
                    //newMonster.renderOrder = .ACTOR
                    
                    // only spawn entities on enterable tiles (i.e. not in the wall)
                    if world.map[newMonster.position].enterable {
                        world.addEntity(entity: newMonster)
                    }
                }
            
                let numberOfItems = random.nextInt(upperBound: 2)
                for _ in 0...numberOfItems {
                    let posX = $0.startX + 1 + random.nextInt(upperBound: $0.width - 2)
                    let posY = $0.startY + 1 + random.nextInt(upperBound: $0.height - 2)
                    if world.map[Coord(posX, posY)].enterable {
                        if Double.random(in: 0 ... 1.0) < 0.5 {
                            let lamp = RLEntity.lamp(startPosition: Coord(posX,posY))

                            if world.map[lamp.position].enterable {
                                world.addEntity(entity: lamp)
                            }
                        } else {
                            let apple = RLEntity.apple(startPosition: Coord(posX, posY))
                            
                            if world.map[apple.position].enterable {
                                world.addEntity(entity: apple)
                            }
                        }
                    }
                }
            }
        
        
        
        //allRooms[mapLevel] = rooms
    }
    
    mutating func createHorizontalTunnel(from: (x:Int, y:Int), to endX:Int) {
        for x in from.x ... endX {
            world.map[Coord(x, from.y - 1)] = world.map[Coord(x, from.y - 1)].enterable == false ? MapCell.wall : MapCell.ground
            world.map[Coord(x, from.y)] = MapCell.ground
            world.map[Coord(x, from.y + 1)] = world.map[Coord(x, from.y + 1)].enterable == false ? MapCell.wall : MapCell.ground
        }
    }
    
    mutating func createVerticalTunnel(from: (x: Int, y: Int), to endY: Int) {
        for y in from.y ... endY {
            world.map[Coord(from.x - 1, y)]  = world.map[Coord(from.x - 1, y)].enterable == false ? MapCell.wall : MapCell.ground
            world.map[Coord(from.x, y)] = MapCell.ground
            world.map[Coord(from.x + 1, y)]  = world.map[Coord(from.x + 1, y)].enterable == false ? MapCell.wall : MapCell.ground
        }
    }
    
    
    mutating func createRoom(mapLevel: Int, startX: Int, startY: Int, width: Int, height: Int) {
        if startY + height >= self.height || startX + width >= self.width {
            return
        }
        
        //print("Creating room at position: (\(startX), \(startY)) with width: \(width) height: \(height)")
        
        for y in startY ..< startY + height {
            for x in startX ..< startX + width {
                if x == startX || x == (startX + width - 1) || y == startY || y == (startY + height - 1) {
                    world.map[Coord(x, y)] = MapCell.wall
                } else {
                    world.map[Coord(x, y)] = MapCell.ground
                }
            }
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
