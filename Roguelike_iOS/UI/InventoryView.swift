//
//  InventoryView.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 23/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct InventoryView: View {
    let fontSize: CGFloat = 24
    var body: some View {
        VStack {
            Text("Inventory: ")
            Text("Head:   Bucket     ")
            Text("L.Hand: Wand       ")
            Text("R.Hand: Shield     ")
            Text("Body:   Light Armor")
            Text("Legs:   Pants      ")
            Text("-------------------------")
            HStack {
                ZStack(alignment: .leading) {
                    Image("Helmet")
                    Text("   Helmet        ")
                }
                ZStack(alignment: .leading) {
                    Image("Helmet")
                    Text("   Helmet        ")
                }
            }
        }.font(.custom("Menlo-Regular", size: self.fontSize)).foregroundColor(Color.white)
            .background(Color.black.opacity(0.75))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
