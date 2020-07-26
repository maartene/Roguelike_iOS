//
//  InventoryView.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 23/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI
import SpriteKit

struct InventoryView: View {
    @ObservedObject var boxedWorld: WorldBox
    let fontSize: CGFloat = 24
    
    var items: [RLEntity] {
        boxedWorld.world.player.inventoryComponent?.items ?? []
    }
    
    func getImage(itemName: String) -> CGImage {
        let tex = RLSprites.getSpriteTextureFor(tileName: itemName)
        tex?.filteringMode = .nearest
        return tex!.cgImage()
    }
    
    var body: some View {
        VStack {
            Text("Inventory: ")
            Text("Head:   Bucket     ")
            Text("L.Hand: Wand       ")
            Text("R.Hand: Shield     ")
            Text("Body:   Light Armor")
            Text("Legs:   Pants      ")
            Text("-------------------------")
            ForEach(items, id: \.id) { item in
                HStack {
                    ZStack(alignment: .leading) {
                        Image(item.name)
                        HStack(spacing: 0) {
                            Text("   \(item.name)    ")
                            if item.consumableEffect != nil {
                                Button("[ Consume ]") {
                                    let consumeAction = ConsumeFromInventoryAction(owner: self.boxedWorld.world.player, item: item)
                                    self.boxedWorld.executeAction(consumeAction)
                                }.background(Color.yellow)
                            }
                        }
                    }
                    
                }
            }
        }.font(.custom("Menlo-Regular", size: self.fontSize)).foregroundColor(Color.white)
            .background(Color.black.opacity(0.75))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        let world = World(width: 10, height: 10)
        let boxedWorld = WorldBox(world: world)
        return InventoryView(boxedWorld: boxedWorld)
    }
}
