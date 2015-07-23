//
//  GameScene.swift
//  The Athlete
//
//  Created by Maxwell James Omdal on 4/4/15.
//  Copyright (c) 2015 Maxwell James Omdal. All rights reserved.
//

import SpriteKit
import iAd
import GameKit

var score: Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    
    let highscoreBox = SKSpriteNode(imageNamed: "HighscoreBox.png")
    //Define the Athlete as a sprite with image named player
    let player = SKSpriteNode(texture: SKTexture(imageNamed: "Player_anim_1.png"))
    var walkingFrames : [SKTexture]!
    //Defines hurdle
    let hurdle = SKSpriteNode(texture: SKTexture(imageNamed: "Anim_Hurdle"))
    let background = SKSpriteNode(imageNamed: "gamebackground.png")
    //Defines the healthbar as a SpriteNode
    var healthBar = SKSpriteNode(imageNamed: "HealthBar.png")
    let back = SKSpriteNode(color: SKColor.grayColor(), size: CGSize(width: 135, height: 40))
    //Define boundary as a node, this keeps other nodes from falling off the screen
    let boundary = SKNode()
    //Keeps too many hurdles from being produced to keep track of
    var hurdleOnScreen = 0
    //Makes sure that SKSpriteNode player cannot jump while already in the air
    var jump = false
    var canJump = true
    //Makes sure that the player has to switch taps on the screen
    var right: Bool?
    var hit = false
    var xValue = 0
    var yValue = 650
    var status: CGFloat = 135
    var restart = false
    var scoreLabel = SKLabelNode(fontNamed: "Press Start K")
    var hide: Bool = false
    
    var val: CGFloat = 0.5

    let startButton = button()
    let leaderBoardButton = button()
    let highScore = SKLabelNode(fontNamed: "Press Start K")
    
    //shows leaderboard screen
    func showLeader() {
        var vc = self.view?.window?.rootViewController
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
        self.paused = true
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, -10)
        physicsWorld.contactDelegate = self
        scoreLabel.position = CGPointMake(size.width/2, size.height*3/4 - 10)
        scoreLabel.fontColor = SKColor.blueColor()
        scoreLabel.fontSize = 20
        addChild(highScore)
        self.healthBar.hidden = true
        self.back.hidden = true
        
        Athlete()
        Boundary()
        Hurdle()
        Background()
        createButtons()
        //Brings up iAds
        showAds()
    }
    
    func showAds() {
        NSNotificationCenter.defaultCenter().postNotificationName("showadsID", object: nil)
    }
    
    class button: SKLabelNode {

        let box: SKSpriteNode
        
        override init() {
            let boxTexture = SKTexture(imageNamed: "box.png")
            boxTexture.filteringMode = SKTextureFilteringMode.Nearest
            self.box = SKSpriteNode(texture: boxTexture)
            super.init()
            self.box.position = CGPointMake(self.position.x, self.position.y + 12)
            self.box.xScale = 2.2
            self.box.yScale = 2.2
            addChild(self.box)
            self.fontName = "Press Start K"
            self.fontColor = SKColor.blueColor()
            self.fontSize = 22
            
            let animation = SKAction.scaleXBy(1.02, y: 1.01, duration: 0.3)
            let animation2 = SKAction.scaleXBy(1.01, y: 1.02, duration: 0.3)
            let complete = SKAction.repeatActionForever(SKAction.sequence([animation, animation2, animation.reversedAction(), animation2.reversedAction()]))
            self.box.runAction(complete)
            self.runAction(complete)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func fade() {
            let fadeOut = SKAction.fadeOutWithDuration(0.5)
            self.runAction(fadeOut, completion: {self.hidden = true})
        }
        
        func fadeIn() {
            let fadeIn = SKAction.fadeInWithDuration(0.5)
            self.runAction(fadeIn)
        }
        
        func animate() {
        }
        
        func touched(touch:Bool) {
            self.box.color = SKColor.grayColor()
            if touch == true {
                self.box.colorBlendFactor = 0.5
            }
            else {
                self.box.colorBlendFactor = 0.0
            }
        }
    }
    
    func createButtons() {
        self.startButton.position = CGPointMake(size.width/2, size.height/4)
        self.highScore.position = CGPointMake(size.width/2, size.height*3/4 + 80)
        self.leaderBoardButton.position = CGPointMake(size.width/2, size.height/4 + 80)
        self.startButton.text = "start"
        self.leaderBoardButton.text = "leaders"
        self.highScore.text = String(NSUserDefaults.standardUserDefaults().integerForKey("score"))
        self.highScore.fontSize = 20
        self.highScore.fontColor = SKColor.blueColor()
        
        addChild(self.startButton)
        addChild(self.leaderBoardButton)
        
        let box = SKTexture(imageNamed: "HighscoreBox.png")
        box.filteringMode = SKTextureFilteringMode.Nearest
        
        highscoreBox.texture = box
        highscoreBox.position = CGPointMake(self.highScore.position.x, self.highScore.position.y + 10)
        highscoreBox.xScale = 2.0
        highscoreBox.yScale = 2.0
        addChild(highscoreBox)
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if hide == true {
                break
            }
            
            else if startButton.frame.contains(location) {
                println("start")
                startButton.fade()
                self.highScore.hidden = true
                leaderBoardButton.fade()
                addChild(scoreLabel)
                self.healthBar.hidden = false
                self.back.hidden = false
                hide = true
                
                hurdle.hidden = false
                
                showHelp()
                Bar()
            }
            
            else if leaderBoardButton.frame.contains(location) {
                println("leaderboard")
                showLeader()
            }
            
            self.leaderBoardButton.touched(false)
            self.startButton.touched(false)
        }
    }
    
    struct physicsCategory {
        static let None :
        UInt32 = 0
        static let all :
        UInt32 = UInt32.max
        static let Player :
        UInt32 = 0b1
        static let Hurdle :
        UInt32 = 0b10
        static let Boundary :
        UInt32 = 0b100
    }

    func Bar() {
        healthBar.size = CGSize(width: 135, height: 40)
        healthBar.zPosition = -1
        
        back.anchorPoint = CGPointMake(0.0, 0.5)
        back.position = CGPointMake(size.width/2 - 70, size.height*3/4)
        back.alpha = 0.5
        back.zPosition = -2
        addChild(back)
        
        let healthBarContainer = SKTexture(imageNamed: "HealthContainer.png")
        healthBarContainer.filteringMode = SKTextureFilteringMode.Nearest
        let barContainer = SKSpriteNode(texture: healthBarContainer)
        barContainer.xScale = 2
        barContainer.yScale = 2
        barContainer.anchorPoint = back.anchorPoint
        barContainer.position = CGPointMake(back.position.x - 7, back.position.y)
        addChild(barContainer)
        
        //Creates a red bar on the top of the screen
        healthBar.anchorPoint = back.anchorPoint
        healthBar.position = back.position
        addChild(healthBar)
    }
    
    func Athlete() {
        //Gives player different properties
        player.position = CGPoint(x: size.width * 0.2, y: size.height/2 + player.size.height/2)
        player.xScale = 2
        player.yScale = 2
        player.zPosition = hurdle.zPosition + 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30, center: CGPointMake(0, -20))
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.categoryBitMask = physicsCategory.Player
        player.physicsBody?.contactTestBitMask = physicsCategory.Hurdle
        player.physicsBody?.collisionBitMask = physicsCategory.Boundary
        addChild(player)
        
        
        //Animates the player's walking movements over and over again
        let playerAtlas = SKTextureAtlas(named: "Player")
        var playerTextures = [SKTexture]()
        let numImages = playerAtlas.textureNames.count
        for i in 1...numImages {
            let texture = playerAtlas.textureNamed("Player_Anim_\(i)")
            texture.filteringMode = SKTextureFilteringMode.Nearest
            playerTextures.append(texture)
        }
        walkingFrames = playerTextures
        let animation = SKAction.animateWithTextures(walkingFrames, timePerFrame: 0.15)
        player.runAction(SKAction.repeatActionForever(animation), withKey: "runningAnimation") //Use runningAnimation as a key for changing the animation to jump, or falling
    }
    
    func Boundary() {
        //Creates a line along the bottom of the screen that acts as the ground
        let point1 = CGPoint(x: -hurdle.size.width/2,y: size.height/2)
        let point2 = CGPoint(x: size.width*2 + hurdle.size.width/2, y: size.height/2)
        boundary.physicsBody = SKPhysicsBody(edgeFromPoint: point1, toPoint: point2)
        boundary.physicsBody?.restitution = 0
        boundary.physicsBody?.categoryBitMask = physicsCategory.Boundary
        boundary.physicsBody?.collisionBitMask = physicsCategory.Hurdle & physicsCategory.Player
        addChild(boundary)
    }
    
    
    func Hurdle() {
        //Gives it a position and different properties
        hurdle.position = CGPoint(x: size.width - hurdle.size.width/2, y: size.height/2 + hurdle.size.height/4)
        hurdle.texture!.filteringMode = SKTextureFilteringMode.Nearest
        hurdle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(hurdle.size.width, hurdle.size.height/4), center: CGPointMake(0.75, 0))
        hurdle.xScale = 1.5
        hurdle.yScale = 1.5
        hurdle.physicsBody?.friction = 0.5
        hurdle.physicsBody?.restitution = 0
        hurdle.physicsBody?.linearDamping = 1
        hurdle.physicsBody?.angularDamping = 0
        hurdle.physicsBody?.allowsRotation = false
        hurdle.physicsBody?.categoryBitMask = physicsCategory.Hurdle
        hurdle.physicsBody?.contactTestBitMask = physicsCategory.Player
        hurdle.physicsBody?.collisionBitMask = physicsCategory.Boundary
        hurdle.physicsBody?.usesPreciseCollisionDetection = true
        hurdle.hidden = true
        addChild(hurdle)
    }
    
    func showHelp() {
        
        let left = SKLabelNode(text: "tap left")
        left.position = CGPointMake(self.size.width/4, self.size.height/3)
        left.fontColor = SKColor.blueColor()
        left.fontName = "Press Start K"
        left.fontSize = 10
        let right = SKLabelNode(text: "then tap right")
        right.position = CGPointMake(self.size.width*3/4, self.size.height/3)
        right.fontColor = SKColor.blueColor()
        right.fontName = "Press Start K"
        right.fontSize = 10
        addChild(left)
        addChild(right)
        
        let j = SKLabelNode(text: "tap here to jump")
        j.position = CGPointMake(self.size.width/2, self.size.height/5 + 20)
        j.fontColor = SKColor.blueColor()
        j.fontName = "Press Start K"
        j.fontSize = 10
        addChild(j)
        
        self.highscoreBox.hidden = true
        
        let texture = SKTexture(imageNamed: "Shoe.png")
        texture.filteringMode = SKTextureFilteringMode.Nearest
        
        let shoe = SKSpriteNode(texture: texture)
        let shoe2 = SKSpriteNode(texture: texture)
        
        shoe.position = CGPointMake(self.size.width/4, self.size.height/3 + 30)
        shoe2.position = CGPointMake(self.size.width*3/4, self.size.height/3 + 30)
        shoe.xScale = 2.0
        shoe.yScale = 2.0
        shoe2.xScale = -2.0
        shoe2.yScale = 2.0
        addChild(shoe)
        addChild(shoe2)
        
        let jumpt = SKTexture(imageNamed: "Jump")
        jumpt.filteringMode = SKTextureFilteringMode.Nearest
        let jumpB = SKSpriteNode(texture: jumpt)
        jumpB.position = CGPointMake(self.size.width/2, self.size.height/5)
        jumpB.xScale = 2.0
        jumpB.yScale = 2.0
        addChild(jumpB)
    }
    
    func Background() {
        //Makes the infinite looping background
        background.anchorPoint = CGPointMake(0.0, 0.0)
        background.position = CGPointMake(0, self.size.height/2)
        background.zPosition = -3
        background.size = CGSizeMake(self.size.width*4, self.size.height/2)
        addChild(background)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //Counts when the player hits the hurdle, and makes sure the player didn't already make contact with the hurdle
        if hit == false {
            println("Player Hit Hurdle")
            self.runAction(SKAction.playSoundFileNamed("Hit_Hurt2.wav", waitForCompletion: false))
            hit = true
            status -= 135
            xValue = xValue/2
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        //First, make sure that everything is ready to go before the game starts, and make sure the game isnt paused
        if hide == true && self.paused == false {
            status = {
                if self.status >= 135 {
                    return 135
                }
                    
                else {
                    return self.status
                }
            }()
            
            let shrink = SKAction.resizeToWidth(status, duration: 0.2)
       
            healthBar.runAction(shrink)
            if status <= 0 && self.healthBar.size.width <= 1 {
                self.runAction(SKAction.playSoundFileNamed("Game_Over_Sound.wav", waitForCompletion: false))
                if score > NSUserDefaults.standardUserDefaults().integerForKey("score") {
                    NSUserDefaults.standardUserDefaults().setObject(score, forKey: "score")
                }
                
                if restart == false {
                    let transition = SKTransition.fadeWithDuration(1)
                    let scene = GameOverScene(size: self.scene!.size)
                    scene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view!.presentScene(scene, transition: transition)
                    restart = true
                }
            }
            
            if right != nil {
                status -= val
            }
            
            hurdle.physicsBody!.velocity = CGVector(dx:xValue, dy:0)
            
            self.background.position = CGPointMake(self.background.position.x + CGFloat(xValue/100), self.background.position.y)
            
            if self.background.position.x <= -self.size.width*2 {
                self.background.position = CGPointMake(0, self.size.height/2)
            }
            
            //returns hurdle when it goes off the screen
            if hurdle.position.x < 0 - hurdle.size.width/2 {
                
                if score%10 == 0 && score != 0 {
                    val += 0.2
                }
                let randomSpot = CGFloat(arc4random_uniform(10))
                hurdle.position.x = size.width + size.width/(randomSpot + 1)
                score += 1
                scoreLabel.text = String(score)
                hit = false
            }
            
            if player.position.y > size.height/2 + player.size.height/2 + 5{
                canJump = false
                jump = false
            }
                
            else {
                canJump = true
                player.paused = false
            }
            
            if jump == true && canJump == true {
                let jumpImg = SKTexture(imageNamed: "Player_Anim_Jump.png")
                jumpImg.filteringMode = SKTextureFilteringMode.Nearest
                player.paused = true
                player.texture = jumpImg
                let jumpVector = CGVector(dx:0, dy:yValue)
                player.physicsBody?.velocity = jumpVector
                jump = false
                xValue -= 15
                self.runAction(SKAction.playSoundFileNamed("Jump2.wav", waitForCompletion: false))
            }
            
            if xValue < -100 && canJump != true {
                xValue += 4
            }
            else if xValue < 2 {
                xValue += 3
            }
            
            yValue = 720 + xValue/3
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>){
            let location = touch.locationInNode(self)
            
            if self.startButton.frame.contains(location) {
                self.startButton.touched(true)
            }
            
            else if self.leaderBoardButton.frame.contains(location) {
                self.leaderBoardButton.touched(true)
            }
                
            else if hide == true && self.paused == false {
                let testBanner = ADBannerView()
                
                if location.y < size.height/4 {
                    jump = true
                }
                    
                else {
                    if (right == false || right == nil) && location.x > size.width/2 {                        xValue -= 39
                        right = true
                        if status < 135 {
                            status += 10
                        }
                    }
                        
                    else if (right == true || right == nil) && location.x < size.width/2 {
                        xValue -= 39
                        right = false
                        if status < 135 {
                            status += 10
                        }
                    }
                }
            }
        }
    }
}


