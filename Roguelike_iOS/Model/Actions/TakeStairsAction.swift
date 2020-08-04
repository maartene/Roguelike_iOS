//
//  TakeStairsAction.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 02/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct TakeStairsAction: Action {
    let owner: RLEntity
    var title: String {
        owner.floorIndex < targetFloor ? "Descend stairs" : "Ascend stairs"
    }
    var description: String {
        "Take stairs to floor \(targetFloor)."
    }
    let stairs: RLEntity
    let targetFloor: Int
    let targetLocation: Coord
    
    func canExecute(in world: World) -> Bool {
        guard let actor = world.entities[owner.id] else {
            print("TakeStairsAction - CANNOT EXECUTE: owner no longer exists in the world.")
            return false
        }
        
        guard Coord.sqr_distance(stairs.position, actor.position) <= 2.00001 else {
            print("TakeStairsAction - CANNOT EXECUTE: stairs out of reach.")
            return false
        }
        
        return true
    }
    
    func execute(in world: World) -> [RLEntity] {
        guard let actor = world.entities[owner.id] else {
            print("TakeStairsAction - CANNOT EXECUTE: owner no longer exists in the world.")
            return []
        }
        
        var changedActor = actor
        changedActor.floorIndex = targetFloor
        changedActor.position = targetLocation
        
        EventSystem.main.fireEvent(.changedFloors(targetFloor))
        return [changedActor]
    }
}
