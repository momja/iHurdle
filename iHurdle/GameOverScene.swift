//
//  GameOverScene.swift
//  The Athlete
//
//  Created by Maxwell James Omdal on 6/11/15.
//  Copyright (c) 2015 Maxwell James Omdal. All rights reserved.
//

import SpriteKit
import GameKit

class GameOverScene: SKScene, GKGameCenterControllerDelegate {
    
    class button: SKLabelNode {
        
        let box: SKSpriteNode
        
        override init() {
            let boxTexture = SKTexture(imageNamed: "box.png")
            boxTexture.filteringMode = SKTextureFilteringMode.Nearest
            self.box = SKSpriteNode(texture: boxTexture)
            super.init()
            self.box.position = CGPointMake(self.position.x, self.position.y + 9)
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
    
    let RestartButton = button()
    let leaderBoard = button()
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.whiteColor()
        
        RestartButton.text = "restart"
        leaderBoard.text = "leaders"
        
        let gameOver = SKLabelNode(text: "Game Over")
        gameOver.fontSize = 20
        gameOver.fontName = "Press Start K"
        gameOver.position = CGPointMake(size.width/2, -50)
        gameOver.fontColor = SKColor.blueColor()
        addChild(gameOver)
        
        let scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.fontName = "Press Start K"
        scoreLabel.position = CGPointMake(size.width/2, size.height*3/4)
        scoreLabel.fontColor = SKColor.blueColor()
        addChild(scoreLabel)
        
        leaderBoard.position = CGPointMake(size.width/2, size.height/4)
        addChild(leaderBoard)
        RestartButton.position = CGPointMake(size.width/2, -50)
        addChild(RestartButton)
        
        saveHighscore(score)
        
        score = 0
        
        let action = SKAction.moveToY(size.height/2, duration: 0.3)
        let action2 = SKAction.moveToY(size.height/2 - 40, duration: 0.3)
        gameOver.runAction(action)
        RestartButton.runAction(action2)
        
    }
    
    func saveHighscore(score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            
            var scoreReporter = GKScore(leaderboardIdentifier: "iHurdle.leaderboard") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            var scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
                if error != nil {
                    println("error")
                }
            })
            
        }
        
    }
    
    //shows leaderboard screen
    func showLeader() {
        var vc = self.view?.window?.rootViewController
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if RestartButton.frame.contains(location) {
                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
                let scene = GameScene(size: self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view!.presentScene(scene, transition: transition)
            }
                
            else if leaderBoard.frame.contains(location) {
                showLeader()
            }
            RestartButton.touched(false)
            leaderBoard.touched(false)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if RestartButton.frame.contains(location) {
                RestartButton.touched(true)
            }
                
            else if leaderBoard.frame.contains(location) {
                leaderBoard.touched(true)
            }
            
        }
    }
}