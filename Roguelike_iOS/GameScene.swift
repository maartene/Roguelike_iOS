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
    var fxController: FXController!
    var spriteUIHandler: SpriteUIHandler!
    var lootManager: LootManager!

    
    @Published var selectedNode: SKNode?
    
    var lastUpdateTime = 0.0
    var timer = 1.0
    
    let highlight: SKSpriteNode
        
    let nextActionDelay: TimeInterval = 0.2
    var actionTimer: TimeInterval = 0
    
    var musicNode: SKAudioNode?
    
    override init() {
        print("regular init")
        let world = WorldBuilder.buildWorld(width: mapSize, height: mapSize)
        boxedWorld = WorldBox(world: world)
        highlight = SKSpriteNode(imageNamed: "highlight")
        
        super.init()
        
        setup()
        
        
    }
        
    override init(size: CGSize) {
        let world = WorldBuilder.buildWorld(width: mapSize, height: mapSize)
        boxedWorld = WorldBox(world: world)
        highlight = SKSpriteNode(imageNamed: "highlight")
        
        super.init(size: size)
        
        setup()
    }
    
    private func setup() {
        backgroundColor = SKColor.black
        
        mapController = MapController(scene: self)
        mapController.mapViewWidth = Int(size.width) / cellSize
        mapController.mapViewHeight = Int(size.height) / cellSize
        mapController.subscribeToWorldChanges(boxedWorld: boxedWorld)
        
        fxController = FXController(scene: self, mapController: mapController)
        fxController.subscribeToWorldChanges(boxedWorld: boxedWorld)
        
        lootManager = LootManager(boxedWorld: boxedWorld)
        lootManager.registerToDieEvents()
        
        boxedWorld.update()
                
        /*spriteUIHandler = SpriteUIHandler(scene: self, mapController: mapController)
        spriteUIHandler.addMovementArrows(to: boxedWorld.world.player)*/
        
        
        highlight.color = SKColor.white
        highlight.colorBlendFactor = 1.0
        highlight.zPosition = HIGHLIGHT_Z_POSITION
        let scaleAction = SKAction.scale(to: 1.1, duration: 0.75)
        let scaleAction2 = SKAction.scale(to: 1.0, duration: 0.75)
        highlight.run(SKAction.repeatForever(SKAction.sequence([scaleAction, scaleAction2])))
        highlight.isHidden = true
        
        if let musicURL = Bundle.main.url(forResource: "Roguelike_lv01", withExtension: "m4a") {
            musicNode = SKAudioNode(url: musicURL)
            let muteAction = SKAction.changeVolume(to: 0, duration: 0)
            let fadeIn = SKAction.changeVolume(to: 0.5, duration: 1)
            
            let sequence = SKAction.sequence([SKAction.pause(), muteAction, SKAction.play(), fadeIn])
            
            musicNode?.autoplayLooped = true
            musicNode?.run(sequence)
            if let mn = musicNode {
                // addChild(mn)
            }
        }
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
                print("Selected tile with position \(tileCoord)")
                selectNode(node)
            } else if let entityID = node.userData?["entityID"] {
                print("Selected entity with id: \(entityID)")
                selectNode(node)
            } else if let action = node.userData?["onClick"] as? (() -> ()) {
                action()
                //mapController.update(world: world)
            } else {
                print("Clicked node: \(node)")
                selectNode(nil)
            }
        } else {
            print("mouseDown \(touch)")
            selectNode(nil)
        }
    }
    
    func newGame() {
        mapController.reset()
        selectedNode = nil
        
        var world = WorldBuilder.buildWorld(width: mapSize, height: mapSize)
        world.update()
        
        boxedWorld.world = world
        boxedWorld.state = .idle
//        boxedWorld.executeAction(WaitAction(owner: boxedWorld.world.player))
    }
    
    func load() {
        mapController.reset()
        selectedNode = nil
        
        boxedWorld.load { [weak self] in
            guard let strongSelf = self else {
                return
            }
            /*strongSelf.spriteUIHandler.addMovementArrows(to: strongSelf.boxedWorld.world.player)*/
        }
    }
    
    func selectNode(_ node: SKNode?) {
        selectedNode = node
        if let sn = node {
            highlight.removeFromParent()
            //highlight.position = sn.position
            sn.addChild(highlight)
            highlight.isHidden = false
        } else {
            highlight.removeFromParent()
            highlight.isHidden = true
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
        
        actionTimer -= deltaTime
        if actionTimer <= 0 {
            boxedWorld.executeNextQueuedAction()
            actionTimer = nextActionDelay
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
