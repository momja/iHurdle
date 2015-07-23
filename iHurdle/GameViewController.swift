//
//  GameViewController.swift
//  The Athlete
//
//  Created by Maxwell James Omdal on 4/4/15.
//  Copyright (c) 2015 Maxwell James Omdal. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import GameKit

class GameViewController: UIViewController, ADBannerViewDelegate {
    
    var SH = UIScreen.mainScreen().bounds.height
    let transition = SKTransition.fadeWithDuration(1)
    var UIiAd: ADBannerView = ADBannerView()
    
    override func viewWillAppear(animated: Bool) {
        var BV = UIiAd.bounds.height
        UIiAd.delegate = self
        UIiAd.frame = CGRectMake(0, SH - BV, 0, 0)
        self.view.addSubview(UIiAd)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIiAd.delegate = nil
        UIiAd.removeFromSuperview()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        var BV = UIiAd.bounds.height
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1) // Time it takes the animation to complete
        UIiAd.alpha = 1 // Fade in the animation
        UIView.commitAnimations()
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1)
        UIiAd.alpha = 0
        UIView.commitAnimations()
    }
    
    func showBannerAd() {
        UIiAd.hidden = false
    }
    
    func hideBannerAd() {
        UIiAd.hidden = true
        var BV = UIiAd.bounds.height
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1) // Time it takes the animation to complete
        UIiAd.frame = CGRectMake(0, SH + BV, 0, 0) // End position of the animation
        UIView.commitAnimations()
    }
    
    override func viewDidLoad() {
        
        authenticateLocalPlayer()
        
        super.viewDidLoad()
        self.UIiAd.hidden = true
        self.UIiAd.alpha = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBannerAd", name: "hideadsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBannerAd", name: "showadsID", object: nil)
        
        let scene = GameScene()
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFit
        scene.size = skView.bounds.size
        self.prefersStatusBarHidden()
        skView.presentScene(scene, transition: transition)
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                let vc: UIViewController = self.view!.window!.rootViewController!
                vc.presentViewController(viewController, animated: true, completion: nil)
            }
                
            else {
                println((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
}




