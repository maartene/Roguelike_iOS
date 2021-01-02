//
//  ActionsView.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 13/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct ActionsView: View {
    
    let boxedWorld: WorldBox
    
    let offset: CGPoint
    let title: String
    let fontSize: CGFloat = 32
    let actions: [Action]
    let sceneSize: CGSize
        
    var topRow: String {
        var result = "\u{2554}"
        result += " " + title + " "
        result += String(repeatElement("\u{2550}", count: max(1, longestLineCount + 4 - title.count - 2)))
        result += "\u{2557}"
        return result
    }
    
    var bottomRow: String {
        var result = "\u{255A}"
        result += String(repeatElement("\u{2550}", count: longestLineCount + 4))
        result += "\u{255D}"
        return result
    }
    
    var options: [String] {
        actions.map { $0.title }
    }
    
    var longestLineCount: Int {
        options.reduce(title.count) { result, line in
            max(result, line.count)
        }
    }
        
    func paddedLine(_ line: String) -> String {
        let padding = longestLineCount - line.count
        return "[" + line + "]" + String(repeating: " ", count: padding)
    }
    
    var calculatedPosition: CGPoint {
        CGPoint(x: offset.x + 140, y: -offset.y + sceneSize.height)
    }
    
    var player: RLEntity {
        boxedWorld.world.player
    }
        
    var body: some View {
        VStack {
            Text(self.topRow).font(.custom("Menlo-Regular", size: fontSize)).foregroundColor(Color.white)
            ForEach(self.actions, id: \.title) { action in
                HStack (spacing: 0) {
                    Text("\u{2551} ").foregroundColor(Color.white)
                    Button(action: {
                        self.boxedWorld.queueActions(action.unpack())
                    }, label: { Text(self.paddedLine(action.title)) }).disabled(action.canExecute(in: self.boxedWorld.world) == false || self.boxedWorld.actionQueue.count > 0).background(Color.yellow)
                    Text(" \u{2551}").foregroundColor(Color.white)
                }.font(.custom("Menlo-Regular", size: self.fontSize))
            }
                
            Text(self.bottomRow).font(.custom("Menlo-Regular", size: fontSize)).foregroundColor(Color.white)
        }.background(Color.black.opacity(0.75))
            .position(calculatedPosition)
    }
}

struct ActionsView_Previews: PreviewProvider {
    static var previews: some View {
        let world = World(width: 10, height: 10)
        let boxedWorld = WorldBox(world: world)
        return ActionsView(boxedWorld: boxedWorld, offset: CGPoint.zero, title: "ACTIONS:", actions:
                            [WaitAction(owner: world.player)], sceneSize: CGSize.zero)
    }
}
