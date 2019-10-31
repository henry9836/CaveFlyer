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
    var playText: SKLabelNode!
    var tutText: SKLabelNode!
    var heli: SKSpriteNode!
    var longPressGestureRecognizer = UILongPressGestureRecognizer()
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    //On start
    override func didMove(to view: SKView){
        //self.backgroundColor = UIColor.gray
        CreateText()
        CreateHeli()
        CreateGestures()
    }
    
    //Gesture Inputs
    @objc func longPress(sender: UILongPressGestureRecognizer){
        let newScene = TutorialScene(size: (self.view?.bounds.size)!)
        let transition = SKTransition.reveal(with: .down, duration: 0.2)
        self.view?.presentScene(newScene, transition: transition)
        transition.pausesOutgoingScene = true
    }
    
    @objc func tap(sender: UITapGestureRecognizer){
        let newScene = GameScene(size: (self.view?.bounds.size)!)
        let transition = SKTransition.reveal(with: .up, duration: 0.2)
        self.view?.presentScene(newScene, transition: transition)
        transition.pausesOutgoingScene = true
    }
    
    //Create Gestures
    func CreateGestures(){
        //Long press
        guard let view = view else { return }
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGestureRecognizer.minimumPressDuration = 1
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        //Tap
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //Create text nodes
    func CreateText(){
        titleText = SKLabelNode()
        titleText.text = "Cave Flyer"
        titleText.fontSize = 32.0
        titleText.fontName = "Copperplate"
        titleText.position = CGPoint(x: self.frame.midX, y: self.frame.midY+150)
        titleText.fontColor = UIColor.white
        self.addChild(titleText)
        
        playText = SKLabelNode()
        playText.text = "Tap To Start"
        playText.fontSize = 14.0
        playText.fontName = "Copperplate"
        playText.position = CGPoint(x: self.frame.midX, y: self.frame.midY+100)
        playText.fontColor = UIColor.white
        self.addChild(playText)
        
        tutText = SKLabelNode()
        tutText.text = "Hold For Tutorial"
        tutText.fontSize = 10.0
        tutText.fontName = "Copperplate"
        tutText.position = CGPoint(x: self.frame.midX, y: self.frame.midY+80)
        tutText.fontColor = UIColor.white
        self.addChild(tutText)
        
        //Animation
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 1.2)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1.2)
        let fadeAction = SKAction.sequence([fadeIn, fadeOut])
        playText.run(SKAction.repeatForever(fadeAction))
    }
    
    //create heli node
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
