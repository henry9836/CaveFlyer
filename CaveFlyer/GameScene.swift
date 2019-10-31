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
    
    let deathPlane: Int = -5500
    let ceilingPlane: Int = 6550
    
    var heli: SKSpriteNode!
    var tilemap: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var tileMap: SKNode!
    var holding: Bool?
    var distanceText: SKLabelNode!
    var altText: SKLabelNode!
    var scoreText: SKLabelNode!
    var startGameText: SKLabelNode!
    var touchFlySide: Bool? //true = flyUp, //false = shoot
    var gameStarted: Bool = false
    var heliSpeed: CGFloat?
    var dead: Bool = false
    //On start
    override func didMove(to view: SKView){
        //self.backgroundColor = UIColor.gray
        holding = false
        touchFlySide = false
        heliSpeed = 3
        
        RemoveGestures()
        CreateTileMap()
        CreateCamera()
        CreateHeli()
        CreateText()
       
    }
    
    //Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameStarted = true
        holding = true
        if let location =  touches.first?.location(in: self.view){
            if (location.x < self.frame.midX){ //user tapped on left side of screen
                touchFlySide = true //shoot and fly
            }
            else{ //user tapped on right side of screen
                touchFlySide = false //shoot
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        holding = false
    }
    
    //Gameloop
    override func update(_ currentTime: TimeInterval) {
       
        if (gameStarted == true){
            //Increase speed over time
            heliSpeed = heliSpeed! + CGFloat(0.05)

            //Get Y
            let yPos = heli.position.y
            
            //Update Text
            distanceText.text = "Distance Flown: \(Int(heli.position.x)/10)"
            altText.text = "Altitude: \(Int(Int(yPos)-deathPlane)-1)"

            //Are we going falling too fast?
            let veloY = (heli.physicsBody?.velocity.dy)!
            if (Float(veloY) < -470.0){
                heli.physicsBody?.velocity.dy = -470.0
            }
            
            //If we have not hit the ground
            if (Int(yPos) > deathPlane && dead == false){
                //move heli forwards
                heli.position.x += (heliSpeed)!;
            }

            //move camera to heli
            cameraNode.position = heli.position

            //move tilemap to make infinite
            WrapTileMap()

            //Check if we should be dead
            print(String(Int(yPos)) + ":" + String(ceilingPlane))
            if ((Int(yPos) < deathPlane) || (Int(yPos) > ceilingPlane)){
                dead = true
            }
            
            if (dead){
                print("Dead")
                //Stop heli
                dead = true
                
                heli.physicsBody?.affectedByGravity = false
                heli.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                if (Int(yPos) < deathPlane){
                    heli.position.y = CGFloat(deathPlane)
                }
                else if (Int(yPos) > ceilingPlane){
                    heli.position.y = CGFloat(ceilingPlane)
                }
                
                //Display score
                
                if (scoreText.text == ""){
                
                    let score = (Int(heli.position.x)/10)
                    
                    //Set current score
                    UserDefaults.standard.set(score, forKey: "currentScore")
                    //Check Highscore
                    if (UserDefaults.standard.integer(forKey: "highScore") < score){
                        UserDefaults.standard.set(score, forKey: "highScore")
                        scoreText.text = "Gameover\nNew HighScore!\nScore: " + String(score)
                    }
                    else{
                        scoreText.text = "Gameover\nScore: " + String(score) + "\n\nHighscore: " + String(UserDefaults.standard.integer(forKey: "highScore"))
                    }
                }
                
            }
            else{
                //player input
                if (holding == true){
                    if (touchFlySide == true){
                        //cap fly up speed
                        let yVelo: Float
                        yVelo = Float(heli.physicsBody?.velocity.dy ?? CGFloat(0))
                        
                        if (yVelo < 500){
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
        }
        else{
            heli.physicsBody?.affectedByGravity = false
        }
    }
    
    func WrapTileMap(){
        let tileSize = 5400
        let d = heli.position.x - tileMap.position.x
        if (d > CGFloat(tileSize - (tileSize/10))){
            tileMap.position.x = heli.position.x
        }
    }
    
    func RemoveGestures(){
        view?.gestureRecognizers?.removeAll()
    }
    
    func CreateText(){
        distanceText = SKLabelNode()
        distanceText.text = ""
        distanceText.fontName = "Copperplate"
        distanceText.fontSize = 32.0
        distanceText.position = CGPoint(x: -85 * cameraNode.xScale, y: 50 * cameraNode.yScale)
        distanceText.fontColor = UIColor.white
        cameraNode.addChild(distanceText) //parent to cam
        
        altText = SKLabelNode()
        altText.text = ""
        altText.fontName = "Copperplate"
        altText.fontSize = 32.0
        altText.position = CGPoint(x: 90 * cameraNode.xScale, y: 50 * cameraNode.yScale)
        altText.fontColor = UIColor.white
        cameraNode.addChild(altText) //parent to cam
        
        scoreText = SKLabelNode()
        scoreText.text = ""
        scoreText.numberOfLines = 0
        scoreText.fontName = "Copperplate"
        scoreText.fontSize = 32.0
        scoreText.position = CGPoint(x: 0, y: 0)
        scoreText.fontColor = UIColor.red
        cameraNode.addChild(scoreText) //parent to cam
        
        startGameText = SKLabelNode()
        startGameText.fontName = "Courier"
        startGameText.text = "Tap to fly"
        startGameText.fontSize = 300.0
        startGameText.position = CGPoint(x: 0, y: 0)
        startGameText.fontColor = UIColor.white
        self.addChild(startGameText) //parent to cam
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
        heli.position = CGPoint(x: 0, y: 0)//25 - 100
        heli.zRotation = (-25.0 * CGFloat(Double.pi/180.0))
        
        //Add Physics
        heli.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        heli.physicsBody?.affectedByGravity = false //only apply gravity once game starts
        heli.physicsBody?.isDynamic = true
        heli.physicsBody?.allowsRotation = false
        heli.physicsBody?.mass = 1.0
        
        
        
        let heliAtlas = SKTextureAtlas(named: "Helicopter")
        let flyAction = SKAction.animate(with: [heliAtlas.textureNamed("f1"), heliAtlas.textureNamed("f2")], timePerFrame: 0.1)
        
        heli.run(SKAction.repeatForever(flyAction))
        
        self.addChild(heli)
        
    }
}
