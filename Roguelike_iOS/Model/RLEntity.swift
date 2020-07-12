//
//  RLEntity.swift
//  RogueLike2
//
//  Created by Maarten Engels on 04/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

struct RLEntity: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case position
        case name
        case hue
        case saturation
        case variables
    }
    
    let id: UUID
    var position: Coord
    let name: String
    let hue: Double
    let saturation: Double
    var variables = [String: Any]()
    
    init(name: String, hue: Double = 0.5, saturation: Double = 1, startPosition: Coord = Coord.zero) {
        self.id = UUID()
        self.name = name
        self.hue = hue
        self.saturation = saturation
        self.position = startPosition
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position, forKey: .position)
        try container.encode(name, forKey: .name)
        try container.encode(hue, forKey: .hue)
        try container.encode(saturation, forKey: .saturation)
        
        let wrappedVariables = try AnyWrapper.wrapperFor(variables)
        try container.encode(wrappedVariables, forKey: .variables)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        position = try values.decode(Coord.self, forKey: .position)
        name = try values.decode(String.self, forKey: .name)
        hue = try values.decode(Double.self, forKey: .hue)
        saturation = try values.decode(Double.self, forKey: .saturation)

        // load preliminary values
        let wrappedVariables = try values.decode(AnyWrapper.self, forKey: .variables)
        variables = wrappedVariables.value as! [String: Any]
    }
    
    func update(in world: World) {
        print("updating")
    }
}

