//
//  Action.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 14/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

protocol Action {
    var title: String { get }
    var description: String { get }
    
    func execute(by actor: RLEntity, in world: World) -> [RLEntity]
    func canExecute(by actor: RLEntity, in world: World) -> Bool
}

extension Action {
    func execute(by actor: RLEntity, in world: World) -> [RLEntity] {
        print("\(actor.name) executed action: \(title).")
        return []
    }
    
    func canExecute(by actor: RLEntity, in world: World) -> Bool {
        return true
    }
}
