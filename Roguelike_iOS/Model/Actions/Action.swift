//
//  Action.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 14/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

protocol Action {
    var owner: RLEntity { get }
    var title: String { get }
    var description: String { get }
    
    func execute(in world: World) -> [RLEntity]
    func canExecute(in world: World) -> Bool
    
    func unpack() -> [Action]
}

extension Action {
    func execute(in world: World) -> [RLEntity] {
        print("\(owner.name) executed action: \(title).")
        return []
    }
    
    func canExecute(in world: World) -> Bool {
        return true
    }
    
    func unpack() -> [Action] {
        [self]
    }
}
