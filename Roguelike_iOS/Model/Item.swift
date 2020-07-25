//
//  Item.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 25/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

protocol Item {
    var name: String { get }
    var description: String { get }
    var statChange: [String: Int] { get }
}

struct Consumable: Item {
    let name: String
    let description: String
    let statChange: [String : Int]
    
    static func minorHealthPotion() -> Consumable {
        let hp = 10
        return Consumable(name: "Minor Health Potion", description: "Heals \(hp) points.", statChange: ["currentHealth": hp])
    }
}

enum EquipmentSlot {
    case head
    case body
    case leftArm
    case rightArm
    case legs
}

struct Equipment: Item {
    let name: String
    let description: String
    let statChange: [String : Int]
    let allowedSlots: [EquipmentSlot]
    
    
    static func sword() -> Equipment {
        Equipment(name: "Sword", description: "Plain old sword.", statChange: ["damage": 1], allowedSlots: [.leftArm, .rightArm])
    }
}
