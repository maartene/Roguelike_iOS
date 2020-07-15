//
//  PlayerStatisticsView.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 10/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct PlayerStatisticsView: View {
    @ObservedObject var boxedWorld: WorldBox
    @State private var isShown = false
    
    var player: RLEntity {
        boxedWorld.world.player
    }
    
    var playerInfoText: [String] {
        let line1 = "HP: ###/###  EXP:  #####   Lvl: ##"
        let line2 = "MP: ###/###  Next: #####   AP: \(ap)"
        return [line1, line2]
    }
    
    var ap: Int {
        player.actionComponent?.currentAP ?? -1
    }
    
    var closeOffset: CGFloat {
        CGFloat((2 + playerInfoText.count) * -26)
    }
    
    var body: some View {
            VStack {
                ConsoleWindowView(lines: self.playerInfoText)
                Image(self.isShown ? "upArrow_32" : "downArrow_32")
                    .offset(x: 0, y: -8)
                    .onTapGesture(perform: { self.isShown.toggle()
                        print("")
                    })
            }.offset(x: 0, y: self.isShown ? 0 : closeOffset)
                .animation(.easeOut(duration: 0.25))
        }
}

struct PlayerStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        let boxedWorld = WorldBox(world: World(width: 10, height: 10))
        return PlayerStatisticsView(boxedWorld: boxedWorld)
    }
}
