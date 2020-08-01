//
//  Constants.swift
//  RogueLike2
//
//  Created by Maarten Engels on 08/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

let ENTITY_Z_POSITION: CGFloat = 10
let FX_Z_POSITION: CGFloat = 30
let HIGHLIGHT_Z_POSITION: CGFloat = 40
let UI_Z_POSITION: CGFloat = 50

extension SKColor {
    var rarityCommon: SKColor {
        SKColor.init(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
    }
    
    var rarityUncommon: SKColor {
        SKColor.init(red: 0.739, green: 0.885, blue: 0.618, alpha: 1)
    }
    
    var rarityRare: SKColor {
        SKColor.init(red: 0, green: 0.590, blue: 1, alpha: 1)
    }
    
    var rarityUnique: SKColor {
        SKColor.init(red: 0.862, green: 0.464, blue: 1, alpha: 1)
    }
    
    var rarityLegendary: SKColor {
        SKColor.init(red: 1, green: 0.831, blue: 0.475, alpha: 1)
    }
    
    var rarityPlayer: SKColor {
        SKColor.init(red: 0, green: 0.991, blue: 1, alpha: 1)
    }
}
