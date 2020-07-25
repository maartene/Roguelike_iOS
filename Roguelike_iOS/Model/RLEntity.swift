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
    
    static func player(startPosition: Coord) -> RLEntity {
        var player = RLEntity(name: "Player", hue: 0.53, saturation: 1, startPosition: startPosition)
        player = VisibilityComponent.add(to: player, addsLight: true, visionRange: 10)
        player = ActionComponent.add(to: player)
        player = HealthComponent.add(to: player, maxHealth: 10, currentHealth: 10, defense: 1, xpOnDeath: 0)
        player = AttackComponent.add(to: player, range: 5, damage: 3)
        player = StatsComponent.add(to: player)
        player = InventoryComponent.add(to: player, size: 10)
        //print(player)
        return player
    }
    
    static func apple(startPosition: Coord) -> RLEntity {
        var apple = RLEntity(name: "Apple", hue: 0.36, saturation: 1, startPosition: startPosition)
        apple = ConsumableEffectComponent.add(to: apple, statChange: ["HC_currentHealth": 7])
        return apple
    }
    
    static func lamp(startPosition: Coord) -> RLEntity {
        var lamp = RLEntity(name: "Lamp", hue: 0.16, saturation: 1, startPosition: startPosition)
        lamp = VisibilityComponent.add(to: lamp, addsLight: true, visionRange: 4)
        return lamp
    }
    
    static func skeleton(startPosition: Coord) -> RLEntity {
        var skeleton = RLEntity(name: "Skeleton", hue: 0, saturation: 0, startPosition: startPosition)
        skeleton = HealthComponent.add(to: skeleton, maxHealth: 5, currentHealth: 5, defense: 0, xpOnDeath: 20)
        //skeleton = AIComponent.add(to: skeleton)
        skeleton = ActionComponent.add(to: skeleton)
        skeleton = AttackComponent.add(to: skeleton, range: 2, damage: 1)
        skeleton = VisibilityComponent.add(to: skeleton, addsLight: false, visionRange: 4)
        return skeleton
    }
    
    static func playerRemains(startPosition: Coord) -> RLEntity {
        var player = RLEntity(name: "Player", hue: 0.09, saturation: 1, startPosition: startPosition)
        player = VisibilityComponent.add(to: player, addsLight: true, visionRange: 3)
        player = HealthComponent.add(to: player, maxHealth: 0, currentHealth: 0, defense: 0, xpOnDeath: 0)
        return player
    }
}

