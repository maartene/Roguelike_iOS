//
//  Utils.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 29/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

extension Int {
    var squared: Double {
        Double(self * self)
    }
}

extension SKColor {
    var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        _ = getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return(hue, saturation, brightness, alpha)
    }
}
