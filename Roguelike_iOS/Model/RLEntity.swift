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
        case floorIndex
        case name
        case variables
        case color
        case rarity
    }
    
    let id: UUID
    var position: Coord
    var floorIndex: Int
    let name: String
    let color: ColorInfo
    let rarity: Rarity?
    var variables = [String: Any]()
    
    init(name: String, color: SKColor = SKColor.white, rarity: Rarity? = nil, floorIndex: Int, startPosition: Coord = Coord.zero) {
        self.id = UUID()
        self.name = name
        self.color = ColorInfo(color)
        self.position = startPosition
        self.floorIndex = floorIndex
        self.rarity = rarity
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position, forKey: .position)
        try container.encode(floorIndex, forKey: .floorIndex)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(rarity, forKey: .rarity)
        
        let wrappedVariables = try AnyWrapper.wrapperFor(variables)
        try container.encode(wrappedVariables, forKey: .variables)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        position = try values.decode(Coord.self, forKey: .position)
        floorIndex = try values.decode(Int.self, forKey: .floorIndex)
        name = try values.decode(String.self, forKey: .name)
        color = try values.decode(ColorInfo.self, forKey: .color)
        rarity = try values.decode(Rarity?.self, forKey: .rarity)
        
        // load preliminary values
        let wrappedVariables = try values.decode(AnyWrapper.self, forKey: .variables)
        variables = wrappedVariables.value as! [String: Any]
    }
    
    func update(in world: World) {
        print("updating")
    }
    
    static func player(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var player = RLEntity(name: "Player", color: SKColor.rarityPlayer, floorIndex: floorIndex, startPosition: startPosition)
        player = VisibilityComponent.add(to: player, addsLight: true, visionRange: 10)
        player = ActionComponent.add(to: player)
        player = HealthComponent.add(to: player, maxHealth: 10, currentHealth: 10, defense: 1, xpOnDeath: 0)
        player = AttackComponent.add(to: player, range: 5, damage: 5)
        player = StatsComponent.add(to: player)
        player = InventoryComponent.add(to: player, size: 10, pickupRange: 2)
        player = EquipmentComponent.add(to: player)
        
        //let sword = RLEntity.sword(startPosition: startPosition)
        //player = player.inventoryComponent!.addItem(sword)
        //print(player)
        return player
    }
    
    static func apple(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var apple = RLEntity(name: "Apple", color: SKColor.green, floorIndex: floorIndex, startPosition: startPosition)
        apple = ConsumableEffectComponent.add(to: apple, statChange: ["HC_currentHealth": 7])
        return apple
    }
    
    static func lamp(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var lamp = RLEntity(name: "Lamp", color: SKColor.yellow, floorIndex: floorIndex, startPosition: startPosition)
        lamp = VisibilityComponent.add(to: lamp, addsLight: true, visionRange: 4)
        return lamp
    }
    
    static func skeleton(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var skeleton = RLEntity(name: "Skeleton", color: SKColor.gray, floorIndex: floorIndex, startPosition: startPosition)
        skeleton = HealthComponent.add(to: skeleton, maxHealth: 5, currentHealth: 5, defense: 0, xpOnDeath: 5)
        //skeleton = AIComponent.add(to: skeleton)
        skeleton = ActionComponent.add(to: skeleton)
        skeleton = AttackComponent.add(to: skeleton, range: 2, damage: 1)
        skeleton = VisibilityComponent.add(to: skeleton, addsLight: false, visionRange: 4)
        return skeleton
    }
    
    static func playerRemains(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var player = RLEntity(name: "Player", color: SKColor.red, floorIndex: floorIndex, startPosition: startPosition)
        player = VisibilityComponent.add(to: player, addsLight: true, visionRange: 3)
        player = HealthComponent.add(to: player, maxHealth: 0, currentHealth: 0, defense: 0, xpOnDeath: 0)
        return player
    }
    
    static func sword(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var sword = RLEntity(name: "Sword", color: SKColor.rarityCommon, floorIndex: floorIndex, startPosition: startPosition)
        sword = EquipableEffectComponent.add(to: sword, statChange: ["AC_damage" : 1], occupiesSlot: .leftArm)
        return sword
    }
    
    static func helmet(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var helmet = RLEntity(name: "Helmet", color: SKColor.rarityCommon, floorIndex: floorIndex, startPosition: startPosition)
        helmet = EquipableEffectComponent.add(to: helmet, statChange: ["HC_defense": 1], occupiesSlot: .head)
        return helmet
    }
    
    static func gold(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var gold = RLEntity(name: "Gold", color: SKColor.yellow, floorIndex: floorIndex, startPosition: startPosition)
        gold = GoldComponent.add(to: gold, amount: 10)
        return gold
    }
    
    static func chest(startPosition: Coord, floorIndex: Int) -> RLEntity {
        var chest = RLEntity(name: "Chest", color: SKColor.rarityUncommon, rarity: Rarity.Uncommon, floorIndex: floorIndex, startPosition: startPosition)
        return chest
    }
}

struct ColorInfo: Codable {
    let hue: CGFloat
    let saturation: CGFloat
    let brightness: CGFloat
    let alpha: CGFloat
    
    var toColor: SKColor {
        return SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
    
    init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1) {
        self.hue = CGFloat(hue)
        self.saturation = CGFloat(saturation)
        self.brightness = CGFloat(brightness)
        self.alpha = CGFloat(alpha)
    }
    
    init(_ skColor: SKColor) {
        let hsb = skColor.hsb
        self.hue = hsb.hue
        self.saturation = hsb.saturation
        self.brightness = hsb.brightness
        self.alpha = hsb.alpha
    }
}
