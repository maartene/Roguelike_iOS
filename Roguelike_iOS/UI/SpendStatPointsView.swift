//
//  SpendStatPoints.swift
//  Roguelike_iOS
//
//  Created by Maarten Engels on 23/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct SpendStatPointsView: View {
    
    @ObservedObject var boxedWorld: WorldBox
    
    let fontSize: CGFloat = 24
    let title = "Character"
    
    var player: RLEntity {
        boxedWorld.world.player
    }
    
    var unspentPoints: Int {
        player.statsComponent?.unspentPoints ?? -1
    }
    
    var strength: Int {
        player.statsComponent?.strength ?? -1
    }
    
    var intelligence: Int {
        player.statsComponent?.intelligence ?? -1
    }
    
    var dexterity: Int {
        player.statsComponent?.dexterity ?? -1
    }
    
    var maxHealth: Int {
        player.healthComponent?.maxHealth ?? -1
    }
    
    var damage: Int {
        player.attackComponent?.damage ?? -1
    }
    
    var defense: Int {
        player.healthComponent?.defense ?? -1
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
    
    func spendPoint(stat: String) {
        let updatedPlayer = player.statsComponent?.spendPoint(on: stat) ?? player
        boxedWorld.world.replaceEntity(entity: updatedPlayer)
    }
    
    var body: some View {
        VStack {
            Text(self.topRow)
            Text("\u{2551} " + paddedLine("Unspent points: \(unspentPoints)") + " \u{2551}")
            HStack(spacing: 0) {
                Text("\u{2551} " + paddedLine("Strength:       \(strength)", extraPadding: unspentPoints > 0 ? -5 : 0))
                if unspentPoints > 0 {
                    Button("[ + ]") {
                        self.spendPoint(stat: "SC_strength")
                        }.background(Color.yellow)
                }
                Text(" \u{2551}")
            }
            HStack(spacing: 0) {
                Text("\u{2551} " + paddedLine("Intelligence:   \(intelligence)", extraPadding: unspentPoints > 0 ? -5 : 0))
                if unspentPoints > 0 {
                    Button("[ + ]") {
                        self.spendPoint(stat: "SC_intelligence")
                    }.background(Color.yellow)
                }
                Text(" \u{2551}")
            }
            HStack(spacing: 0) {
                Text("\u{2551} " + paddedLine("Dexterity:      \(dexterity)", extraPadding: unspentPoints > 0 ? -5 : 0))
                if unspentPoints > 0 {
                    Button("[ + ]") {
                        self.spendPoint(stat: "SC_dexterity")
                    }.background(Color.yellow)
                }
                Text(" \u{2551}")
            }
            
            Text("\u{255F}" + String(repeatElement("\u{2500}", count: windowWidth + 2)) + "\u{2562}")
            
            Text("\u{2551} " + paddedLine("HP:      \(maxHealth)") + " \u{2551}")
            Text("\u{2551} " + paddedLine("Damage:  \(damage)") + " \u{2551}")
            Text("\u{2551} " + paddedLine("Defense: \(defense)") + " \u{2551}")
            Text(self.bottomRow)
        }.font(.custom("Menlo-Regular", size: fontSize)).foregroundColor(Color.white)
            .background(Color.black.opacity(0.75))
    }
}

struct SpendStatPointsViewContainer: View {
    @ObservedObject var boxedWorld: WorldBox
    @State private var isShown = false
    
    let windowWidth = 25
    
    var closeOffset: CGFloat {
        CGFloat((2 + windowWidth) * -16)
    }
    
    var unspentPoints: Int {
        boxedWorld.world.player.statsComponent?.unspentPoints ?? -1
    }
    
    var body: some View {
        HStack {
            SpendStatPointsView(boxedWorld: boxedWorld, windowWidth: windowWidth)
            Image(self.isShown ? "leftArrow_32" : "rightArrow_32")
                //.overlay(Circle().size(CGSize(width: 32, height: 32)).foregroundColor(Color.clear))
                .shadow(color: Color.yellow, radius: unspentPoints > 0 && self.isShown == false ? 8 : 0, x: 0, y: 0)
                .shadow(color: Color.yellow, radius: unspentPoints > 0 && self.isShown == false ? 8 : 0, x: 0, y: 0)
                .offset(x: 16, y: 0)
                .onTapGesture(perform: { self.isShown.toggle()
    //                print("")
                })
        }.offset(x: self.isShown ? 0 : closeOffset, y: 0)
            .animation(.easeOut(duration: 0.25))
    }
}

struct SpendStatPointsView_Previews: PreviewProvider {
    static var previews: some View {
        let world = World(width: 10, height: 10)
        let boxedWorld = WorldBox(world: world)
        return SpendStatPointsView(boxedWorld: boxedWorld, windowWidth: 25)
    }
}
