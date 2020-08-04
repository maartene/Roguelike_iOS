//
//  RLSprites.swift
//  RogueLike2
//
//  Created by Maarten Engels on 04/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct RLSprites {
    
    static private var sprites = ["Wooden Floor": Coord(17, 31),
                          "Double_Wall_N_S_": Coord(14, 27),
                          "Double_Wall__E_W": Coord(32, 27),
                          "Double_Wall___SW": Coord(33, 27),
                          "Double_Wall_N__W": Coord(34, 27),
                          "Double_Wall_NE__": Coord(35, 27),
                          "Double_Wall__ES_": Coord(15, 27),
                          "Double_Wall___S_": Coord(14, 27),
                          "Double_Wall_N___": Coord(37, 27),
                          "Double_Wall__E__": Coord(38, 27),
                          "Double_Wall____W": Coord(36, 27),
                          "Double_Wall__ESW": Coord(39, 27),
                          "Double_Wall_N_SW": Coord(40, 27),
                          "Double_Wall_NE_W": Coord(41, 27),
                          "Double_Wall_NES_": Coord(17, 27),
                          "Double_Wall_NESW": Coord(16, 27),
                          "Stairs_Up": Coord(2, 25),
                          "Stairs_Down": Coord(3, 25),
                          "Player": Coord(25, 30),
                          "Lamp": Coord(3, 16),
                          "FullSquare": Coord(32, 26),
                          "DitherSquare_16th": Coord(33, 26),
                          "EmptySquare": Coord(0, 31),
                          "Brick_Wall": Coord(10, 14),
                          "UpArrow_OL": Coord(28, 11),
                          "RightArrow_OL": Coord(29, 11),
                          "DownArrow_OL": Coord(30, 11),
                          "LeftArrow_OL": Coord(31, 11),
                          "UpArrow_Short_OL": Coord(23, 10),
                          "RightArrow_Short_OL": Coord(24, 10),
                          "DownArrow_Short_OL": Coord(25, 10),
                          "LeftArrow_Short_OL": Coord(26, 10),
                          
                          // Pickups
                          "Apple": Coord(15, 2),
                          "Gold": Coord(15,20),
                          // Equipment
                          "Sword": Coord(0,1),
                          "Helmet": Coord(1,9),
                          // Monsters
                          "Skeleton": Coord(27, 26),
                          "Evil Knight": Coord(31,31),
                          "Spider": Coord(28,26),
                          "Ghost": Coord(27,25),
                          "Bat": Coord(26,23),
                          "Snake": Coord(28,23),
                          
    ]
    
    static private var instance = RLSprites()
    
    private init() {
        texture = SKTexture(imageNamed: "monochrome_transparent_32")
        spriteWidth = 32
        spriteHeight = 32
        margin = 0
    }
    
    private let texture: SKTexture
    private let spriteWidth: Int
    private let spriteHeight: Int
    private let margin: Int
    
    private var indexSpriteMap = [Coord: SKTexture]()
    
    private var rowCount: Int {
        Int(texture.size().height) / (margin + spriteHeight)
    }
    
    private var colCount: Int {
        Int(texture.size().width) / (margin + spriteWidth)
    }
    
    private var numSprites: Int {
        return rowCount * colCount
    }
    
    mutating private func getSpriteWith(xIndex: Int, yIndex: Int) -> SKTexture? {
        guard (0 ..< colCount).contains(xIndex) && (0 ..< rowCount).contains(yIndex) else {
            print("Out of bounds: \(xIndex), \(yIndex)")
            return nil
        }
        
        if let tex = indexSpriteMap[Coord(xIndex, yIndex)] {
            //print("Found cached texture")
            return tex
        }
        
        let x = Double(xIndex * (margin + spriteWidth)) / Double(texture.size().width)
        let y = Double(yIndex * (margin + spriteHeight)) / Double(texture.size().height)
        
        let rect = CGRect(x: x, y: y, width: Double(spriteWidth) / Double(texture.size().width), height: Double(spriteHeight) / Double(texture.size().height))
        let tex = SKTexture(rect: rect, in: texture)
        indexSpriteMap[Coord(xIndex, yIndex)] = tex
        return tex
    }
    
    static func getSpriteTextureFor(tileName: String) -> SKTexture? {
        guard tileName != "void" else {
            return nil
        }
        
        guard let coord = RLSprites.sprites[tileName] else {
            print("Could not find texture coordinates for tile with name \(tileName).")
            return nil
        }
        
        return instance.getSpriteWith(xIndex: coord.x, yIndex: coord.y)
    }
}
