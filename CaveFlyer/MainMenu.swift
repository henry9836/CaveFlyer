//
//  MainMenu.swift
//  CaveFlyer
//
//  Created by Henry Oliver on 21/10/19.
//  Copyright © 2019 Henry Oliver. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {
    var titleText: SKLabelNode!
    var heli: SKSpriteNode!
    
    override func didMove(to view: SKView){
        //self.backgroundColor = UIColor.gray
        CreateText()
        CreateHeli()
    }
    
    func CreateText(){
        titleText = SKLabelNode()
        titleText.text = "Cave Flyer"
        titleText.fontSize = 32.0
        //mainMenuTitle.fontName = "AvenirNext-Bold"
        titleText.position = CGPoint(x: self.frame.midX, y: self.frame.midY+100)
        titleText.fontColor = UIColor.white
        self.addChild(titleText)
    }
    
    func CreateHeli(){
        
        heli = SKSpriteNode(texture: SKTexture(imageNamed: "f1"), size: CGSize(width: 300, height: 300))
        heli.position = CGPoint(x: self.frame.midX, y: self.frame.midY-25)//25 - 100
        heli.zRotation = (-25.0 * CGFloat(Double.pi/180.0))
        
        //Animation
        let heliAtlas = SKTextureAtlas(named: "Helicopter")
        let flyAction = SKAction.animate(with: [heliAtlas.textureNamed("f1"), heliAtlas.textureNamed("f2")], timePerFrame: 0.1)
        let hoverDown = SKAction.moveTo(y: self.frame.midY-100, duration: 1.0)
        let hoverUp = SKAction.moveTo(y: self.frame.midY-25, duration: 1.0)
        let hoverAction = SKAction.sequence([hoverDown, hoverUp])
        
        heli.run(SKAction.repeatForever(flyAction))
        heli.run(SKAction.repeatForever(hoverAction))
        
        self.addChild(heli)
        
    }
    
}
