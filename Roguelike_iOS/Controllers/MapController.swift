//
//  MapController.swift
//  RogueLike2
//
//  Created by Maarten Engels on 08/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import Combine

final class MapController {
    
    let mapNode: SKNode
    let entityNode: SKNode
    var mapViewWidth = 0
    var mapViewHeight = 0
    
    var mapNodeMap = [Coord: SKSpriteNode]()
    var entityNodeMap = [UUID: SKSpriteNode]()
    
    let scene: GameScene
    let cellSize: Int
    
    var floorToShow = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(scene: GameScene) {
        self.scene = scene
        self.cellSize = scene.cellSize
        
        mapNode = SKNode()
        entityNode = SKNode()
        scene.addChild(mapNode)
        scene.addChild(entityNode)
    }
    
    func subscribeToWorldChanges(boxedWorld: WorldBox) {
        boxedWorld.$world.sink(receiveCompletion: { completion in
            print("Received completion value: \(completion).")
        }, receiveValue: { [weak self] world in
            print("update world received")
            self?.update(world: world)
            }).store(in: &cancellables)
        
        EventSystem.main.$lastEvent.sink(receiveValue: { [weak self] event in
            switch event {
            case .changedFloors(let newFloor):
                print("Changing floors")
                self?.floorToShow = newFloor
                self?.reset()
            default:
                break
            }
            }).store(in: &cancellables)
    }
    
    func update(world: World) {
        showMap(world: world)
        showEntities(world: world)        
        deleteSprites(world: world)
    }
    
    func reset() {
        mapNodeMap.removeAll()
        entityNodeMap.removeAll()
        mapNode.removeAllChildren()
        entityNode.removeAllChildren()
    }
    
    func showMap(world: World) {
        for node in mapNodeMap.values {
            node.isHidden = true
        }
        
        let playerPos = world.player.position
        let halfMapViewWidth = mapViewWidth / 2
        let halfMapViewHeight = mapViewHeight / 2
        
        let floor = world.floors[floorToShow]
        
        for viewY in 0 ..< mapViewHeight {
            for viewX in 0 ..< mapViewWidth {
                let mapCoord = Coord(viewX, viewY) + playerPos - Coord(halfMapViewWidth, halfMapViewHeight)
                
                let mapCell = floor.map[mapCoord]
                
                if let node = mapNodeMap[mapCoord] {
                    node.isHidden = false
                    node.position = CGPoint(x: viewX * cellSize + cellSize / 2, y: viewY * cellSize + cellSize / 2)
                    if world.allVisibleTiles.contains(mapCoord) {
                        node.color = SKColor(hue: CGFloat(mapCell.hue), saturation: CGFloat(mapCell.saturation), brightness: CGFloat(mapCell.light * mapCell.maxBrightness), alpha: 1)
                    } else {
                        node.color = SKColor(hue: CGFloat(mapCell.hue), saturation: 0, brightness: CGFloat(mapCell.visitedBrightness), alpha: 1)
                    }
                    
                    
                } else if mapCell.visited {
                    if let tex = RLSprites.getSpriteTextureFor(tileName: world.getSpriteNameFor(mapCell, at: mapCoord)) {
                        tex.filteringMode = .nearest
                        let node = SKSpriteNode(texture: tex)
                        //print(tex.size())
                        node.position = CGPoint(x: viewX * cellSize + cellSize / 2, y: viewY * cellSize + cellSize / 2)
                        node.setUserData(key: "position", value: mapCoord)
                        node.color = SKColor(hue: CGFloat(mapCell.hue), saturation: CGFloat(mapCell.saturation), brightness: CGFloat(mapCell.light * mapCell.maxBrightness), alpha: 1)
                        node.colorBlendFactor = 1.0
                        mapNode.addChild(node)
                        mapNodeMap[mapCoord] = node
                    }
                }
            }
        }
    }

    func showEntities(world: World) {
        let playerPos = world.player.position
        let halfMapViewWidth = mapViewWidth / 2
        let halfMapViewHeight = mapViewHeight / 2
        
        let floor = world.floors[floorToShow]
        
        for entity in world.entitiesOnCurrentFloor {
            let viewPos = entity.position - playerPos + Coord(halfMapViewWidth, halfMapViewHeight)
            
            if entityNodeMap[entity.id] == nil {
                createSpriteForEntity(entity)
            }
            
            if let sprite = entityNodeMap[entity.id] {
                if world.allVisibleTiles.contains(entity.position) {
                    sprite.isHidden = false
                    sprite.position = CGPoint(x: viewPos.x * cellSize + cellSize / 2, y: viewPos.y * cellSize + cellSize / 2)
                    sprite.color = SKColor(hue: entity.color.hue, saturation: entity.color.saturation, brightness: CGFloat(max(floor.map[entity.position].light, 0.5)), alpha: 1)
                //} else if world.map[entity.position].visited {
                    //sprite.position = CGPoint(x: viewPos.x * cellSize + 8, y: viewPos.y * cellSize + 8)
                    //sprite.color = SKColor(hue: CGFloat(entity.hue), saturation: CGFloat(entity.saturation), brightness: 0, alpha: 1)
                } else {
                    sprite.isHidden = true
                }
            } /*else if world.allVisibleTiles.contains(entity.position) {
                guard let sc = entity.spriteComponent else {
                    print("No SpriteComponent attached to entity \(entity).")
                    return
                }
                                
                sc.node.position = CGPoint(x: viewPos.x * cellSize + 8, y: viewPos.y * cellSize + 8)
                sc.node.color = SKColor(hue: CGFloat(entity.hue), saturation: CGFloat(entity.saturation), brightness: CGFloat(max(world.map[entity.position].light, 0.5)), alpha: 1)
                addChild(sc.node)
            }*/
        }
    }
    
    func deleteSprites(world: World) {
        let spritesToDelete = entityNodeMap.filter { entry in
            world.entities.keys.contains(entry.key) == false
        }
        
        for entry in spritesToDelete {
            entry.value.removeFromParent()
            entityNodeMap.removeValue(forKey: entry.key)
        }
    }
    
    func createSpriteForEntity(_ entity: RLEntity) {
        let node: SKSpriteNode
        if let tex = RLSprites.getSpriteTextureFor(tileName: entity.name) {
            tex.filteringMode = .nearest
            node = SKSpriteNode(texture: tex)
        } else {
            node = SKSpriteNode()
        }
                    
        node.name = entity.name
        node.zPosition = ENTITY_Z_POSITION
        node.colorBlendFactor = 1
        //node.color = SKColor(hue: CGFloat(entity.hue), saturation: CGFloat(entity.saturation), brightness: 1, alpha: 1)
        node.setUserData(key: "entityID", value: entity.id)
        
        entityNodeMap[entity.id] = node
        entityNode.addChild(node)
    }
}
