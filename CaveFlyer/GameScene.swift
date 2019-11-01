//
//  GameScene.swift
//  CaveFlyer
//
//  Created by Henry Oliver on 21/10/19.
//  Copyright © 2019 Henry Oliver. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Main Game
    
    let deathPlane: Int = -5500
    let ceilingPlane: Int = -4300
    
    var obstacle: SKShapeNode!
    var ceiling: SKShapeNode!
    var ceilingVis: SKShapeNode!
    var floor: SKShapeNode!
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
    let maxSpeed: Int = 40
    var dead: Bool = false
    
    enum BitMasks{
        static let kill: UInt32 = 0b001
        static let heli: UInt32 = 0b010
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //collision with death spot
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BitMasks.heli | BitMasks.kill){
            dead = true
        }
    }
    
    //On start
    override func didMove(to view: SKView){
        //self.backgroundColor = UIColor.gray
        holding = false
        touchFlySide = false
        heliSpeed = 10
        
        physicsWorld.contactDelegate = self
        
        RemoveGestures()
        CreateTileMap()
        CreateCamera()
        CreateHeli()
        CreateShapes()
        CreateText()
       
    }
    
    //Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameStarted = true
        holding = true
        if (dead == false){
            if let location =  touches.first?.location(in: self.view){
                if (location.x < self.frame.midX){ //user tapped on left side of screen
                    touchFlySide = true //shoot and fly
                }
                else{ //user tapped on right side of screen
                    touchFlySide = false //shoot
                }
                
            }
        }
        //Game is over
        else{
            if let location =  touches.first?.location(in: self.view){
                if (location.x < self.frame.midX){ //Left Side = restart
                    heli.position = CGPoint(x: -1000, y: deathPlane+650)
                    heliSpeed = 10
                    heli.physicsBody?.velocity = CGVector(dx: 0, dy: 0) //Reset physics
                    tileMap.position.x = heli.position.x
                    scoreText.text = ""
                    dead = false
                }
                else{ //Right Side = Quit to main menu
                    let newScene = MainMenuScene(size: (self.view?.bounds.size)!)
                    let transition = SKTransition.reveal(with: .down, duration: 0.2)
                    self.view?.presentScene(newScene, transition: transition)
                    transition.pausesOutgoingScene = true
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        holding = false
    }
    
    //Gameloop
    override func update(_ currentTime: TimeInterval) {
       
        //move death planes with heli
        floor.position.x = heli.position.x
        ceiling.position.x = heli.position.x
        
        if (gameStarted == true){
            //Increase speed over time
            if (heliSpeed! < CGFloat(maxSpeed)){
                heliSpeed = heliSpeed! + CGFloat(0.05)
            }
            //Get Y
            let yPos = heli.position.y
            
            //Update Text
            distanceText.text = "Distance Flown: \(Int(heli.position.x+1000)/10)"
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
            cameraNode.position.x += 1000;

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
                
                distanceText.text = "Restart"
                altText.text = "Quit"
                
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
                
                    let score = (Int(heli.position.x+1000)/10)
                    
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
            //game
            else{
                
                //Respawn obstacle
                if (obstacle.position.x < (heli.position.x - CGFloat(1000))){

                    //destroy node
                    obstacle.removeFromParent()
                    self.obstacle = nil
                    
                    //recreate node
                    let mySize: CGSize = CGSize(width: CGFloat.random(in: 100 ..< 500), height: CGFloat.random(in: 100 ..< 500))
                    
                    obstacle = SKShapeNode(rectOf: mySize)
                    obstacle.fillColor = UIColor.red
                    obstacle.position = heli.position
                    obstacle.position.x += 3500
                    obstacle.position.y = CGFloat.random(in: -5500 ..< -4300)
                    obstacle.physicsBody = SKPhysicsBody(rectangleOf: mySize)
                    obstacle.physicsBody?.affectedByGravity = false
                    obstacle.physicsBody?.isDynamic = false
                    obstacle.physicsBody?.categoryBitMask = BitMasks.kill;
                    obstacle.physicsBody?.contactTestBitMask = BitMasks.heli;
                    
                    self.addChild(obstacle)
                }
                
                
                //player input
                if (holding == true){
                    if (touchFlySide == true){
                        //cap fly up speed and pew pew
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
        let tileSize = 4500
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
        startGameText.position = CGPoint(x: 0, y: deathPlane+650)
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
        cameraNode?.position = CGPoint(x: 0, y: deathPlane+650)
        self.camera = cameraNode
        self.addChild(cameraNode)
        
    }
    
    func CreateHeli(){
        heli = SKSpriteNode(texture: SKTexture(imageNamed: "f1"), size: CGSize(width: 100, height: 100))
        heli.position = CGPoint(x: -1000, y: deathPlane+650)//25 - 100
        heli.zRotation = (-25.0 * CGFloat(Double.pi/180.0))
        
        //Add Physics
        heli.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        heli.physicsBody?.affectedByGravity = false //only apply gravity once game starts
        heli.physicsBody?.isDynamic = true
        heli.physicsBody?.allowsRotation = false
        heli.physicsBody?.mass = 1.0
        heli.physicsBody?.categoryBitMask = BitMasks.heli;
        //heli.physicsBody?.contactTestBitMask = BitMasks.kill | CategoryBitMask.enemy;
        heli.physicsBody?.contactTestBitMask = BitMasks.kill;
        heli.name = "heli"
        
        
        let heliAtlas = SKTextureAtlas(named: "Helicopter")
        let flyAction = SKAction.animate(with: [heliAtlas.textureNamed("f1"), heliAtlas.textureNamed("f2")], timePerFrame: 0.1)
        
        heli.run(SKAction.repeatForever(flyAction))
        
        self.addChild(heli)
        
    }
    
    func CreateShapes(){
        ceiling = SKShapeNode(rectOf: CGSize(width: 1000, height: 100))
        ceiling.position = CGPoint(x: 0, y: ceilingPlane)
        ceiling.name = "topKill"
        ceilingVis = SKShapeNode(rectOf: CGSize(width: 10000000, height: 10000000))
        ceilingVis.position = CGPoint(x: 0, y: ceilingPlane + (10000000/2))
        ceilingVis.fillColor = UIColor.darkGray
        
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 1))
        ceiling.physicsBody?.affectedByGravity = false
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = BitMasks.kill;
        ceiling.physicsBody?.contactTestBitMask = BitMasks.heli;
        
        self.addChild(ceiling)
        self.addChild(ceilingVis)
        
        floor = SKShapeNode(rectOf: CGSize(width: 1000, height: 100))
        floor.position = CGPoint(x: 0, y: deathPlane)
        floor.name = "bottomKill"
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 1))
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = BitMasks.kill;
        floor.physicsBody?.contactTestBitMask = BitMasks.heli;
        
        self.addChild(floor)
        
        obstacle = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
        obstacle.fillColor = UIColor.red
        obstacle.position = CGPoint(x: -100000, y: deathPlane*10)//hide it
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = BitMasks.kill;
        obstacle.physicsBody?.contactTestBitMask = BitMasks.heli;
        
        self.addChild(obstacle)
    }
}
