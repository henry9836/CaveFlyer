//
//  GameScene.swift
//  CaveFlyer
//
//  Created by Henry Oliver on 21/10/19.
//  Copyright © 2019 Henry Oliver. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //Main Game
    
    let deathPlane: Int = -5400
    
    var heli: SKSpriteNode!
    var tilemap: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var tileMap: SKNode!
    var holding: Bool?
    var touchFlySide: Bool? //true = flyUp, //false = shoot
    
    var heliSpeed: CGFloat?
    //On start
    override func didMove(to view: SKView){
        //self.backgroundColor = UIColor.gray
        holding = false
        touchFlySide = false
        heliSpeed = 3
        
        RemoveGestures()
        CreateTileMap()
        CreateCamera()
        CreateText()
        CreateHeli()
       
    }
    
    //Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        holding = true
        if let location =  touches.first?.location(in: self.view){
            if (location.x < self.frame.midX){ //user tapped on left side of screen
                touchFlySide = true
            }
            else{ //user tapped on right side of screen
                touchFlySide = false
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        holding = false
    }
    
    //Gameloop
    override func update(_ currentTime: TimeInterval) {

        //move heli forwards
        heli.position.x += (heliSpeed)!;

        //move camera to heli
        cameraNode.position = heli.position
        
        //Check if we hit the ground
        let yPos = heli.position.y
        if (Int(yPos) < deathPlane){
            print("Dead")
        }
        
        //player input
        if (holding == true){
            if (touchFlySide == true){
                //cap fly up speed
                let yVelo: Float
                yVelo = Float(heli.physicsBody?.velocity.dy ?? CGFloat(0))
                
                if (yVelo < 600){
                    //fly up
                    heli.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy:100.0))
                    
                    print(heli.position.y)
                }
            }
            else{
                //pew pew
                heli.position = CGPoint(x: self.frame.midX-50, y: self.frame.midY)//25 - 100
                heli.physicsBody?.affectedByGravity = false
                heli.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            }
        }
        else{
            heli.physicsBody?.affectedByGravity = true
        }
    }
    
    func RemoveGestures(){
        view?.gestureRecognizers?.removeAll()
    }
    
    func CreateText(){
        
    }
    
    func CreateTileMap(){
        //Create main node
        tileMap = SKNode()
        addChild(tileMap)
        
        //scale down tile map so we can see more
        tileMap.setScale(CGFloat(0.8))
        
        //Load TileSet
        let tileSet = SKTileSet(named: "GameTileSet")
        let tileSize = CGSize(width: 128, height: 128)
        let columns = Int(tileSize.width)
        let rows = Int(tileSize.height)
        
        //Load Tiles
        let rockTile = tileSet?.tileGroups.first { $0.name == "Cobblestone" }
        let groundTile = tileSet?.tileGroups.first { $0.name == "Sand" }
        
        let backgroundLayer = SKTileMapNode(tileSet: tileSet!, columns: columns, rows: rows, tileSize: tileSize)
        backgroundLayer.fill(with: rockTile)
        
        let groundLayer = SKTileMapNode(tileSet: tileSet!, columns: columns, rows: rows, tileSize: tileSize)
        
        //Place ground tiles
        for column in 0 ..< columns {
            for row in 0 ..< rows{
                //Only set bottom few tiles to ground
                if (row < (0 + (rows/10))){
                    groundLayer.setTileGroup(groundTile, forColumn: column, row: row)
                }
            }
        }
        
        tileMap.addChild(backgroundLayer)
        tileMap.addChild(groundLayer)
        
    }
    
    func CreateCamera(){
        cameraNode = SKCameraNode()
        cameraNode?.setScale(3)
        cameraNode?.position = CGPoint(x: 0, y: 0)
        self.camera = cameraNode
        self.addChild(cameraNode)
        
    }
    
    func CreateHeli(){
        heli = SKSpriteNode(texture: SKTexture(imageNamed: "f1"), size: CGSize(width: 50, height: 50))
        heli.position = CGPoint(x: self.frame.midX-50, y: self.frame.midY)//25 - 100
        heli.zRotation = (-25.0 * CGFloat(Double.pi/180.0))
        
        //Add Physics
        heli.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        heli.physicsBody?.affectedByGravity = true
        heli.physicsBody?.isDynamic = true
        heli.physicsBody?.allowsRotation = false
        heli.physicsBody?.mass = 1.0
        
        
        
        let heliAtlas = SKTextureAtlas(named: "Helicopter")
        let flyAction = SKAction.animate(with: [heliAtlas.textureNamed("f1"), heliAtlas.textureNamed("f2")], timePerFrame: 0.1)
        
        heli.run(SKAction.repeatForever(flyAction))
        
        self.addChild(heli)
        
    }
}
