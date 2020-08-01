//
//  InventoryView.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 23/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI
import SpriteKit

struct ItemInfo: View {
    @Binding var item: RLEntity?
    var windowWidth = 35
    
    func addExplicitSign(_ value: Int) -> String {
        if value >= 0 {
            return "+\(value)"
        } else {
            return "\(value)"
        }
    }
    
    var itemText: [String] {
        guard let item = item else {
            return []
        }
        
        var result = [String]()
        
        if let equipment = item.equipableEffect {
            for effect in equipment.statChange {
                result.append("\(effect.key): \(addExplicitSign(effect.value))")
            }
            result.append("Slot: \(equipment.occupiesSlot)")
        } else if let consumable = item.consumableEffect {
            for effect in consumable.statChange {
                result.append("\(effect.key): \(addExplicitSign(effect.value))")
            }
            result.append("Consumable")
        }
        return result
    }
    
    var body: some View {
        ConsoleWindowView(title: item?.name ?? "unknown", windowWidth: windowWidth, lines: itemText).onTapGesture {
            self.item = nil
        }
    }
    
}

struct InventoryView: View {
    @State var showItemDetails: RLEntity?
    @ObservedObject var boxedWorld: WorldBox
    let title = "Inventory"
    let fontSize: CGFloat = 24
    
    var items: [RLEntity] {
        boxedWorld.world.player.inventoryComponent?.items ?? []
    }
    
    var gold: Int {
        boxedWorld.world.player.inventoryComponent?.gold ?? 0
    }
    
    func getImage(itemName: String) -> CGImage {
        let tex = RLSprites.getSpriteTextureFor(tileName: itemName)
        tex?.filteringMode = .nearest
        return tex!.cgImage()
    }
    
    let windowWidth: Int
    
    var topRow: String {
        var result = "\u{2554}"
        result += " " + title + " "
        result += String(repeatElement("\u{2550}", count: max(1, windowWidth + 4 - title.count - 4)))
        result += "\u{2557}"
        return result
    }
    
    var bottomRow: String {
        var result = "\u{255A}"
        result += String(repeatElement("\u{2550}", count: windowWidth + 2))
        result += "\u{255D}"
        return result
    }
    
    func paddedLine(_ line: String, extraPadding: Int = 0) -> String {
        let padding = windowWidth - line.count + extraPadding
        return line + String(repeating: " ", count: padding)
    }
    
    func equipmentLine(_ slot: EquipmentSlot) -> some View {
        let item = boxedWorld.world.player.equipmentComponent?.equippedSlots[slot, default: nil]
        return HStack(spacing: 0) {
            Text("\u{2551} ")
            Text("\(padded(String(describing: slot), width: 7)): ")
                ZStack(alignment: .leading) {
                    Image(item?.name ?? "Clear")
                    Text("   \(padded(item?.name ?? "empty", width: item != nil ? windowWidth - 7 - 5 - 11 : windowWidth - 7 - 5))").foregroundColor(item != nil ? Color.white : Color.gray).onTapGesture {
                        self.showItemDetails = item
                    }
                }
            if item != nil {
                Button("[ Unequip ]") {
                    let unequipAction = UnequipToInventoryAction(owner: self.boxedWorld.world.player, slot: slot)
                    self.boxedWorld.executeAction(unequipAction)
                }.background(Color.purple)
            }
            Text(" \u{2551}")
        }
    }
    
    func padded(_ string: String, width: Int) -> String {
        let padding = width - string.count
        return string + String(repeating: " ", count: padding)
    }
    
    var slots: [EquipmentSlot] {
        guard let ec = boxedWorld.world.player.equipmentComponent else {
            return []
        }
        let slots = Array(ec.equippedSlots.keys)
        return slots.sorted(by: {$0.description > $1.description})
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(topRow)
            ForEach(self.slots, id: \.description) { slot in
                self.equipmentLine(slot)
            }
            //self.equipmentLine(.leftArm)
            Text("\u{255F}" + String(repeatElement("\u{2500}", count: windowWidth + 2)) + "\u{2562}")
            ForEach(items, id: \.id) { item in
                HStack {
                    ZStack(alignment: .leading) {
                        Image(item.name).offset(x: 16, y: 0).colorMultiply(Color(hue: item.hue, saturation: item.saturation, brightness: 1))
                        HStack(spacing: 0) {
                            if item.consumableEffect != nil {
                                Text("\u{2551} " + "  \(self.paddedLine(item.name, extraPadding: -13))").onTapGesture {
                                    self.showItemDetails = item
                                }
                                Button("[ Consume ]") {
                                    let consumeAction = ConsumeFromInventoryAction(owner: self.boxedWorld.world.player, item: item)
                                    self.boxedWorld.executeAction(consumeAction)
                                }.background(Color.yellow)
                                Text(" \u{2551}")
                            }
                            if item.equipableEffect != nil {
                                Text("\u{2551} " + "  \(self.paddedLine(item.name, extraPadding: -11))")
                                .onTapGesture {
                                    self.showItemDetails = item
                                }
                                Button("[ Equip ]") {
                                    let equipAction = EquipFromInventoryAction(owner: self.boxedWorld.world.player, item: item, slot: item.equipableEffect?.occupiesSlot ?? .leftArm)
                                    self.boxedWorld.executeAction(equipAction)
                                }.background(Color.purple)
                                Text(" \u{2551}")
                            }
                        }
                    }
                    
                }
            }
            Text("\u{255F}" + String(repeatElement("\u{2500}", count: windowWidth + 2)) + "\u{2562}")
            Text("\u{2551} " + paddedLine("Gold: \(gold)") + " \u{2551}")
            Text(bottomRow)
            if showItemDetails != nil {
                ItemInfo(item: $showItemDetails, windowWidth: windowWidth)
            }
        }.font(.custom("Menlo-Regular", size: self.fontSize)).foregroundColor(Color.white)
            .background(Color.black.opacity(0.75))
    }
}

struct InventoryViewContainer: View {
    @ObservedObject var boxedWorld: WorldBox
    @State private var isShown = false
    
    let windowWidth = 35
    
    var closeOffset: CGFloat {
        CGFloat((2 + windowWidth) * 16)
    }
    
    var body: some View {
        HStack {
            Image(self.isShown ? "rightArrow_32" : "leftArrow_32")
                //.overlay(Circle().size(CGSize(width: 32, height: 32)).foregroundColor(Color.clear))
                .offset(x: -16, y: 0)
                .onTapGesture(perform: { self.isShown.toggle()
    //                print("")
                })
            InventoryView(boxedWorld: boxedWorld, windowWidth: windowWidth)
        }.offset(x: self.isShown ? 0 : closeOffset - 8, y: 0)
            .animation(.easeOut(duration: 0.25))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        var world = World(width: 10, height: 10)
        let sword = RLEntity.sword(startPosition: Coord.zero)
        let helmet = RLEntity.helmet(startPosition: Coord.zero)
        let apple = RLEntity.apple(startPosition: Coord.zero)
        var player = world.player.inventoryComponent?.addItem(sword) ?? world.player
        player = player.inventoryComponent?.addItem(apple) ?? player
        player = player.equipmentComponent?.equipItem(helmet, in: .head) ?? player
        world.replaceEntity(entity: player)
        let boxedWorld = WorldBox(world: world)
        return InventoryView(boxedWorld: boxedWorld, windowWidth: 35)
    }
}
