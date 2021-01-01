//
//  Rarity.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 02/08/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

enum Rarity: Int, Codable {
    case Common
    case Uncommon
    case Rare
    case Unique
    case Legendary
    
    var color: SKColor {
        switch self {
        case .Common:
            return SKColor.rarityCommon
        case .Uncommon:
            return SKColor.rarityUncommon
        case .Rare:
            return SKColor.rarityRare
        case .Unique:
            return SKColor.rarityUnique
        case .Legendary:
            return SKColor.rarityLegendary
        }
    }
    
    var statChange: Int {
        switch self {
        case .Uncommon:
            return 1
        case .Rare:
            return 2
        case .Unique:
            return 0    // Unique items and monsters have specific set stats
        case .Legendary: // Legendary items and monsters have specific set stats.
            return 0
        default:
            return 0
        }
    }
    
    func clamped(maxRarity: Rarity) -> Rarity {
        if self.rawValue > maxRarity.rawValue {
            return maxRarity
        } else {
            return self
        }
    }
}
