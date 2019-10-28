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
    
    var heli: SKSpriteNode!
    var holdGestureRecognizer = UILongPressGestureRecognizer()
    var holding: Bool?
    var touchFlySide: Bool? //true = flyUp, //false = shoot
    //On start
    override func didMove(to view: SKView){
        //self.backgroundColor = UIColor.gray
        holding = false
        touchFlySide = false
        RemoveGestures()
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
        //
        if (holding == true){
            if (touchFlySide == true){
                //cap fly up speed
                let yVelo: Float
                yVelo = Float(heli.physicsBody?.velocity.dy ?? CGFloat(0))
                
                if (yVelo < 400){
                    //fly up
                    heli.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy:50.0))
                    
                    print(yVelo)
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
