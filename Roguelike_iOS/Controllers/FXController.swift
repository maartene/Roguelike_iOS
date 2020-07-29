//
//  FXController.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 18/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import Combine
import SpriteKit

final class FXController {
    let fxNode: SKEffectNode
    
    weak var scene: GameScene?
    weak var mapController: MapController?
    weak var boxedWorld: WorldBox?
    
    let cellSize: Int
    
    var eventIndex = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(scene: GameScene, mapController: MapController) {
        self.scene = scene
        self.mapController = mapController
        self.cellSize = scene.cellSize
        
        fxNode = SKEffectNode()
        let filter = CIFilter.init(name: "CIBloom", parameters: ["inputRadius": NSNumber(value: 15),
        "inputIntensity": NSNumber(value: 1)])
        assert(filter != nil)
        fxNode.filter = filter
        fxNode.shouldEnableEffects = true
        fxNode.blendMode = .add
        scene.addChild(fxNode)
    }
    
    func subscribeToWorldChanges(boxedWorld: WorldBox) {
        self.boxedWorld = boxedWorld
        boxedWorld.$lastExecutedAction.sink(receiveCompletion: { completion in
            print("Received completion value: \(completion).")
        }, receiveValue: { [weak self] lastExecutedAction in
            if let lea = lastExecutedAction {
                self?.createEffect(for: [lea])
            }
        }).store(in: &cancellables)
        
        /*boxedWorld.$removedEntities.sink(receiveValue: {[weak self] removedEntities in
            self?.createEffect(for: removedEntities)
            }).store(in: &cancellables)*/
        
        EventSystem.main.$lastEvent.sink(receiveValue: {[weak self] event in
            self?.createEffect(for: event)
            }).store(in: &cancellables)
    }
    
    func createEffect(for actions: [Action]) {
        guard let world = boxedWorld?.world else {
            return
        }
        
        if let newAction = actions.last {
            if let action = newAction as? AttackAction {
                let projectile = SKNode()
                projectile.zPosition = FX_Z_POSITION
                projectile.position = mapController?.entityNodeMap[action.owner.id]?.position ?? CGPoint.zero
                fxNode.addChild(projectile)
                
                let targetCoord = action.target.position - action.owner.position
                let doubleResTargetCoord = targetCoord * 2
                
                
                let sortedLineCoords = Coord.plotLine(from: Coord(0,0), to: doubleResTargetCoord)

                // ß®print(sortedLineCoords)
                
                let screenCoords: [CGPoint] = sortedLineCoords.map { coord -> CGPoint in
                    CGPoint(x: coord.x * cellSize / 2, y: coord.y * cellSize / 2)
                }
                
                let tex = SKTexture(imageNamed: "doubleRes_full")
                
                tex.filteringMode = .nearest
                
                for i in 0 ..< screenCoords.count {
                    let pixel = SKSpriteNode(texture: tex)
                    pixel.colorBlendFactor = 1.0
                    pixel.color = SKColor.yellow
                    pixel.alpha = 0
                    projectile.addChild(pixel)
                    pixel.position = screenCoords[i]
                    
                    let w = SKAction.wait(forDuration: 0.01 * Double(i))
                    let fi = SKAction.fadeIn(withDuration: 0.15)
                    pixel.run(SKAction.sequence([w, fi, SKAction.removeFromParent()]))
                }
                
                projectile.run(SKAction.sequence([SKAction.wait(forDuration: 4), SKAction.removeFromParent()]))
                
                let touchedTiles = Coord.plotLine(from: action.owner.position, to: action.target.position)
                
                let fxedTiles = touchedTiles.map { coord -> FxTile in
                    FxTile(coord: coord, tile: world.map[coord], highlightBrightnessToAdd: 1)
                }
                
                let neighbourTiles = touchedTiles.flatMap { coord in coord.neighbourCoordinates }
                let fxedNeighbours = neighbourTiles.map { coord -> FxTile in
                    FxTile(coord: coord, tile: world.map[coord], highlightBrightnessToAdd: 0.5)
                }
                
                let diagonalNeighbours = touchedTiles.flatMap { coord in coord.diagonalNeighbourCoordinates}
                let fxedDiagonalNeighbours = diagonalNeighbours.map { coord -> FxTile in
                    FxTile(coord: coord, tile: world.map[coord], highlightBrightnessToAdd: 0.25)
                }
                
                let affectedTiles: Set<FxTile> = Set(fxedTiles).union(fxedNeighbours).union(fxedDiagonalNeighbours)
                
                let sortedAffectedTiles = affectedTiles.sorted { Coord.sqr_distance(action.owner.position, $0.coord) < Coord.sqr_distance(action.owner.position, $1.coord) }
                
                for i in 0 ..< sortedAffectedTiles.count {
                    let tile = sortedAffectedTiles[i]
                    if let sprite = mapController?.mapNodeMap[tile.coord] {
                        //let w = SKAction.wait(forDuration: Double(i) * 0.1)
                        let hl = SKAction.colorize(with: tile.highlightColor, colorBlendFactor: 1, duration: 0.15)
                        sprite.run(hl) {
                            //print("Resetting to original color: \(tile.originalColor)")
                            sprite.color = tile.originalColor
                        }
                    }
                }
                
            } else if let action = newAction as? MoveAction {
                return
                if action.owner.id != world.player.id {
                    if let sprite = mapController?.entityNodeMap[action.owner.id], let targetLocationSprite = mapController?.mapNodeMap[action.targetLocation] {
                    
                        let m = SKAction.move(to: targetLocationSprite.position, duration: 1)
                        sprite.run(m)
                    }
                }
            }
        }
    }
    
    /*func createEffect(for removedEntities: [RLEntity]) {
        for entity in removedEntities {
            if entity.healthComponent != nil {
            explosion(at: entity.position, range: 1, color: SKColor(hue: CGFloat(entity.hue), saturation: CGFloat(entity.saturation), brightness: 1, alpha: 1))
            } else {
                // do nothing
            }
        }
    }*/
    
    func createEffect(for event: RLEvent) {
        switch event {
        case .entityDied(let entity):
            explosion(at: entity.position, range: 1, color: SKColor(hue: CGFloat(entity.hue), saturation: CGFloat(entity.saturation), brightness: 1, alpha: 1))
        case .levelup(let entity):
            scaleSpriteEffect(for: entity)
        default:
            print("Create effect for \(event)")
        }
    }
    
    func scaleSpriteEffect(for entity: RLEntity) {
        if let sprite = mapController?.entityNodeMap[entity.id] {
            if let tex = sprite.texture {
                tex.filteringMode = .nearest
                let fxSprite = SKSpriteNode(texture: tex)
                fxSprite.color = SKColor(hue: CGFloat(entity.hue), saturation: CGFloat(entity.saturation), brightness: 1, alpha: 1)
                fxSprite.blendMode = .screen
                fxSprite.colorBlendFactor = 1
                fxSprite.zPosition = FX_Z_POSITION
                fxSprite.position = sprite.position
                
                let scaleAction = SKAction.scale(to: 10, duration: 1)
                let fadeOutAction = SKAction.fadeOut(withDuration: 1)
                let actions = SKAction.group([scaleAction, fadeOutAction])
                fxSprite.run(SKAction.sequence([actions, SKAction.removeFromParent()]))
                fxNode.addChild(fxSprite)
            }
        }
    }
    
    func explosion(at coord: Coord, range: Int, color: SKColor = SKColor.white) {
        for y in coord.y - range ... coord.y + range {
            for x in coord.x - range ... coord.x + range {
                if Coord(x, y).manhattanDistance(to: coord) <= range {
                    if let sprite = mapController?.mapNodeMap[Coord(x,y)], let tile = boxedWorld?.world.map[coord] {
                        let fxTile = FxTile(coord: coord, tile: tile, highlightBrightnessToAdd: 4)
                        
                        let hl = SKAction.colorize(with: fxTile.highlightColor, colorBlendFactor: 1, duration: 0.25)
                        let w = SKAction.wait(forDuration: 0.5)
                        sprite.run(SKAction.sequence([hl, w])) {
                            sprite.color = fxTile.originalColor
                        }
                    }
                }
            }
        }
        
        let screenCenter = mapController?.mapNodeMap[coord]?.position ?? CGPoint.zero
        for r in 0 ... range * 2 {
            let circleCoords = Array(Coord.circleBres(center: Coord.zero, radius: r))
            for i in 0 ..< circleCoords.count {
                let pixel = SKSpriteNode(imageNamed: "doubleRes_full")
                pixel.zPosition = FX_Z_POSITION
                pixel.colorBlendFactor = 1.0
                pixel.color = color
                pixel.alpha = 0
                pixel.position = CGPoint(x: screenCenter.x + CGFloat(cellSize * circleCoords[i].x) / 2, y: screenCenter.y + CGFloat(cellSize * circleCoords[i].y / 2))
                fxNode.addChild(pixel)
                
                let w = SKAction.wait(forDuration: Double(r) * 0.01)
                let fi = SKAction.fadeIn(withDuration: 0.15)
                let fo = SKAction.fadeOut(withDuration: 0.15)
                pixel.run(SKAction.sequence([w,fi,fo,SKAction.removeFromParent()]))
            }
        }
    }
    
    struct FxTile: Hashable {
        let coord: Coord
        let originalColor: SKColor
        let highlightColor: SKColor
        
        init(coord: Coord, tile: MapCell, highlightBrightnessToAdd: CGFloat = 1) {
            self.coord = coord
            originalColor = SKColor(hue: CGFloat(tile.hue), saturation: CGFloat(tile.saturation), brightness: tile.lightedBrightness, alpha: 1)
            highlightColor = SKColor(hue: CGFloat(tile.hue), saturation: CGFloat(tile.saturation), brightness:    tile.lightedBrightness + highlightBrightnessToAdd * CGFloat(tile.maxBrightness), alpha: 1)
        }
    }
}
