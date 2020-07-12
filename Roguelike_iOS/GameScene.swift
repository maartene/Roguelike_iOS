//
//  GameScene.swift
//  RogueLike2
//
//  Created by Maarten Engels on 04/07/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit
import Combine

class GameScene: SKScene, ObservableObject {

    var boxedWorld: WorldBox
    
    let mapSize = 64
    let cellSize = 32
        
    var mapController: MapController!
    var spriteUIHandler: SpriteUIHandler!
    
    var draggedNode: SKNode?
    
    var lastUpdateTime = 0.0
    var timer = 1.0
    
    let messageLabel = SKLabelNode()
    
    @Published var worldState: WorldBox.WorldBoxState = .idle
    
    override init() {
        let world = World(width: 80, height: 45)
        boxedWorld = WorldBox(world: world)
        
        super.init()
        
        backgroundColor = SKColor.black
        
        mapController = MapController(scene: self)
        mapController.mapViewWidth = Int(size.width) / cellSize
        mapController.mapViewHeight = Int(size.height) / cellSize
        mapController.subscribeToWorldChanges(boxedWorld: boxedWorld)
        
        boxedWorld.update()
                
        spriteUIHandler = SpriteUIHandler(scene: self, mapController: mapController)
        spriteUIHandler.addMovementArrows(to: boxedWorld.world.player)
    }
    
    override init(size: CGSize) {
        let world = WorldBuilder.buildWorld(width: mapSize, height: mapSize)
        boxedWorld = WorldBox(world: world)
        super.init(size: size)
        
        backgroundColor = SKColor.black
        
        mapController = MapController(scene: self)
        mapController.mapViewWidth = Int(size.width) / cellSize
        mapController.mapViewHeight = Int(size.height) / cellSize
        mapController.subscribeToWorldChanges(boxedWorld: boxedWorld)
        
        //boxedWorld.update()
                
        spriteUIHandler = SpriteUIHandler(scene: self, mapController: mapController)
        spriteUIHandler.addMovementArrows(to: boxedWorld.world.player)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*override func didMove(to view: SKView) {
        
        
        /*GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let error = error {
                print("Error while signing in: \(error)")
            } else if let vc = viewController {
                print("Received viewcontroller.")
            }
        }*/
        
        
        //addMovementArrows()
        //world.player.addComponent(ControlComponent(owner: world.player, spriteComponent: world.player.spriteComponent!, scene: self))
    }*/
        
    /**/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view = view else {
            return
        }
        
        let scenePoint = convertPoint(fromView: touch.location(in: view))
        if let node = nodes(at: scenePoint).first {
            if let tileCoord = node.userData?["position"] {
                print("Clicked tile with position \(tileCoord)")
            } else if let action = node.userData?["onClick"] as? (() -> ()) {
                action()
                //mapController.update(world: world)
            } else {
                print("Clicked node: \(node)")
                draggedNode = node
            }
        } else {
            print("mouseDown \(touch)")
        }
    }
    
    func load() {
        mapController.reset()
        boxedWorld.load { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.spriteUIHandler.addMovementArrows(to: strongSelf.boxedWorld.world.player)
        }
    }
    
    /*override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
    
        switch key.keyCode {
        case .keyboardLeftArrow:           // left arrow
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(-1,0))
            world.update()
        case .keyboardRightArrow:
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(1, 0))
            world.update()
        case .keyboardDownArrow:
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(0, -1))
            world.update()
        case .keyboardUpArrow:
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(0, 1))
            world.update()
        default:
            print("keyCode: \(key.keyCode)")
        }
        
        mapController.update(world: world)
        //print("presses \(presses)")
        
    }*/
    /*
    override func mouseDragged(with event: NSEvent) {
        print("mouseDragged \(event)")
        if let node = draggedNode {
            let scenePoint = convertPoint(fromView: event.locationInWindow)
            if let parent = node.parent {
                let nodePoint = convert(scenePoint, to: parent)
                node.position = nodePoint
            } else {
                node.position = scenePoint
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        print("mouseUp \(event)")
        draggedNode = nil
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:           // left arrow
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(-1,0))
            world.update()
        case 124:           // right arrow
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(1, 0))
            world.update()
        case 125:           // down arrow
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(0, -1))
            world.update()
        case 126:           // up arrow
            world.moveEntity(entity: world.player, newPosition: world.player.position + Coord(0, 1))
            world.update()
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
        
        mapController.update(world: world)
    }*/

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if lastUpdateTime == 0.0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if boxedWorld.state != worldState {
            worldState = boxedWorld.state
            
            if worldState == .idle {
                messageLabel.removeFromParent()
            } else if worldState == .loading || worldState == .saving {
                messageLabel.text = "\(worldState.rawValue) -  please wait"
                messageLabel.fontName = "Menlo-Regular"
                messageLabel.position = CGPoint(x: frame.midX, y: frame.midY)
                addChild(messageLabel)
            }
            
        }
        
/*        if timer < 0 {
            timer = 0.25
            resetLight()
            lightPass(lampCoord: world.map.keys.randomElement() ?? Coord(0,0))
            showMap()
        }
        timer -= deltaTime*/
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        //print("size changed")
        guard let mc = mapController else {
            return
        }
        
        mc.mapViewWidth = Int(size.width) / cellSize
        mc.mapViewHeight = Int(size.height) / cellSize
        
        mc.update(world: boxedWorld.world)
    }
}

extension SKColor {
    static var randomHue: SKColor {
        SKColor(hue: CGFloat(Float.random(in: 0.0...1.0)), saturation: 1, brightness: 1, alpha: 1)
    }
    
    
}
