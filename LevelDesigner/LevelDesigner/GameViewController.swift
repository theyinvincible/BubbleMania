//
//  GameEngine.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 12/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit
import Darwin

class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var LaunchButton: UIButton!
    @IBOutlet var cannon: UIView!
    private var gameEngine: GameEngine?
    private var launchAngle = M_PI/2
    private var currentFrame: UIView?
    private var gridData: BubbleGrid?
    
    func setGridData(gridDesign: BubbleGrid) {
        gridData = gridDesign
        //gameEngine = GameEngine(gridData: gridDesign, viewFrame: view.frame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameEngine = GameEngine(gridData: gridData!, viewFrame: self.view.frame)

        // set gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        if gameEngine == nil{
            print("game engine is nil")
        }
        currentFrame = gameEngine!.getView()
        view.addSubview(currentFrame!)

        // redraws scene at 60 frames per second
        _ = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self, selector: "updateView", userInfo: nil, repeats: true)
    }
    
    /// updates positions of objects and renders the frame accordingly
    func updateView() {
        currentFrame?.removeFromSuperview()
        currentFrame = gameEngine!.getView()
        view.addSubview(currentFrame!)
        
        // draw cannon
        cannon.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2 - launchAngle))
        self.view.addSubview(cannon)
        self.view.bringSubviewToFront(LaunchButton)
        
       // displayPrelaunchBubbles()
    }

    /// Handles launch button, launches the projectile bubble launchBubble
    @IBAction func launchBubble(sender: AnyObject?) {
        // nothing happens if a bubble is in the air
        gameEngine?.launch()
      //  if !bubbleIsLaunching {
        //    angleOfLaunchedBubble = launchAngle
          //  bubbleIsLaunching = true
        //}
    }
    
    /// handles tap gesture on game area for selection of angle
    func handleTap(tapRecognizer: UITapGestureRecognizer) {
        let point = tapRecognizer.locationInView(self.view)
        let changeX = point.x - (self.view.frame.width)/2
        let changeY = (self.view.frame.height) - point.y
        let gradient = Double(changeY/changeX)
        launchAngle = atan(gradient)
        if launchAngle < 0 {
            launchAngle += M_PI
        }
        gameEngine!.updateAngle(launchAngle)
    }
}


