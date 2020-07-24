//
//  WorldBox.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 12/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import Combine

final class WorldBox: ObservableObject {
    enum WorldBoxState: String {
        case idle
        case loading
        case saving
        case updating
        case gameover
    }
    
    @Published var world: World
    @Published var state: WorldBoxState = .idle
    @Published var lastExecutedAction: Action?
    @Published var removedEntities = [RLEntity]()
    
    var actionQueue = [Action]()
    
    init(world: World) {
        self.world = world
    }
    
    func update() {
        guard state == .idle else {
            print("Can only update in state 'idle'.")
            return
        }
        
        state = .updating
        var updatedWorld = world
        DispatchQueue.global().async {
            updatedWorld.update()
            DispatchQueue.main.async {
                self.world = updatedWorld
                //print("Update done.")
                self.state = .idle
            }
        }
    }
    
    func updateAI(entityID: UUID) {
        guard state == .idle else {
            print("Can only update in state 'idle'.")
            return
        }
        
        guard let entity = world.entities[entityID] else {
            return
        }
        
        guard let vc = entity.visibilityComponent, let ac = entity.attackComponent else {
            return
        }
        // if entity can see the player
        if vc.visibleTiles.contains(world.player.position) || entity.healthComponent?.currentHealth ?? 0 < entity.healthComponent?.maxHealth ?? 0 {
                // are we close enough to attack the player?
            if entity.position.manhattanDistance(to: world.player.position) <= ac.range {
                // close enough, lets attack!
                let attackAction = AttackAction(owner: entity, damage: ac.damage, range: ac.range, target: world.player)
                    actionQueue.insert(attackAction, at: 0)
            } else {
                // need to move closer
                let movementLine = Coord.plotLine(from: entity.position, to: world.player.position)
                
                if movementLine.count > 1 {
                    let moveAction = MoveAction(owner: entity, targetLocation: movementLine[1], map: world.map)
                    actionQueue.insert(moveAction, at: 0)
                }
            }
        }
    }
    
    
    func queueAction(_ action: Action) {
        actionQueue.append(action)
    }
    
    func queueActions(_ actions: [Action]) {
        actionQueue.append(contentsOf: actions)
    }
    
    func executeNextQueuedAction() {
        if actionQueue.count > 0 {
            executeAction(actionQueue.removeFirst())
        }
    }
    
    func executeAction(_ action: Action) {
        guard state == .idle else {
            print("Can only execute in state 'idle'.")
            return
        }
        
        removedEntities = []
        
        lastExecutedAction = action
        
        let updatedEntities = action.execute(in: world)
        world.replaceEntities(entities: updatedEntities)
    
        if (action.owner.id == world.player.id) {
            for entityID in world.entities.keys.filter({ $0 != world.player.id }) {
                updateAI(entityID: entityID)
            }
        }
        
        removedEntities = world.pruneEntities()
        if world.player.healthComponent?.isDead ?? false {
            state = .gameover
        }
        
        world.update()
    }
    
    func save() {
        guard state == .idle else {
            print("Can only save in state 'idle'.")
            return
        }
        state = .saving
        
        DispatchQueue.global().async {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                // pretend to be doing *actual* work
                sleep(1)
                
                let data = try encoder.encode(self.world)
                /*let localPlayer = GKLocalPlayer.local
                localPlayer.saveGameData(data, withName: "RogueLike", completionHandler: { saveGame, error in
                    if let error = error {
                        print("Error saving game: \(error)")
                    } else if let saveGame = saveGame {
                        print("Succesfully saved game: \(saveGame)")
                    }
                })*/
                let homeDir = FileManager.default.temporaryDirectory
                let url = homeDir.appendingPathComponent("rogueLikeSave.json")
                try data.write(to: url)
                DispatchQueue.main.async {
                    print("Save done.")
                    self.state = .idle
                }
            } catch {
                print("Error: \(error)")
                self.state = .idle
            }
        }
        
    }
    
    func load(onLoadFinished: (() -> ())? = nil) {
        guard state == .idle else {
            print("Can only save in state 'idle'.")
            return
        }
        state = .loading
        
        DispatchQueue.global().async {
            do {
                let decoder = JSONDecoder()
                
                // pretend to be doing *actual* work
                sleep(1)
                
                let homeDir = FileManager.default.temporaryDirectory
                let url = homeDir.appendingPathComponent("rogueLikeSave.json")
                
                let data = try Data(contentsOf: url)
                let loadedWorld = try decoder.decode(World.self, from: data)
                //print(String(data: data, encoding: .utf8))
                DispatchQueue.main.async {
                    self.world = loadedWorld
                    print("Loading done")
                    onLoadFinished?()
                    self.state = .idle
                }
            } catch {
                DispatchQueue.main.async {
                    print("Loading done")
                    onLoadFinished?()
                    self.state = .idle
                }
            }
        }
    }
}
