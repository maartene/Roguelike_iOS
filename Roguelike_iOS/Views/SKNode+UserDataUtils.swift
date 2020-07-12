//
//  SKNode+UserDataUtils.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 12/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    func setUserData(key: String, value: Any) {
        if let ud = userData {
            ud[key] = value
        } else {
            userData = [key: value]
        }
    }
}
