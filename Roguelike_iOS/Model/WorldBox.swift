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
    }
    
    @Published var world: World
    @Published var state: WorldBoxState = .idle
    @Published var executedActions = [Action]()
    @Published var removedEntities = [RLEntity]()
    
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
    
    func executeAction(_ action: Action) {
        guard state == .idle else {
            print("Can only execute in state 'idle'.")
            return
        }
        
        removedEntities = []
        
        executedActions.append(action)
        
        let updatedEntities = action.execute(in: world)
        world.replaceEntities(entities: updatedEntities)
        removedEntities = world.pruneEntities()
        
        world.calculateLighting()
        
        
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
                print("Error: \(error)")
            }
        }
        
    }
}
