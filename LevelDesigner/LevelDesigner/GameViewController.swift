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
    @IBOutlet var pausebutton: UIButton!
    
    private var launchAngle = Constants.startingLaunchAngle
    private var gridData: BubbleGrid?
    private var gameEngine: GameEngine?
    private var currentFrame: UIView?
    
    func setGridData(gridDesign: BubbleGrid) {
        gridData = gridDesign
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameEngine = GameEngine(gridData: gridData!, viewFrame: self.view.frame)

        // set gesture recognizer for launch angle selection
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        currentFrame = gameEngine!.getView()
        view.addSubview(currentFrame!)

        // redraws game scene at 60 frames per second
        _ = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self, selector: "updateView", userInfo: nil, repeats: true)
    }
    
    /// updates positions of objects and renders the frame accordingly
    func updateView() {
        if pause {
            return
        }
        currentFrame?.removeFromSuperview()
        currentFrame = gameEngine!.getView()
        view.addSubview(currentFrame!)
        
        // draw cannon rotation
        cannon.transform = CGAffineTransformMakeRotation(CGFloat(Constants.startingLaunchAngle - launchAngle))
        self.view.addSubview(cannon)
        self.view.bringSubviewToFront(LaunchButton)
        self.view.bringSubviewToFront((pausebutton))
    }
    
    var pause = false
    @IBAction func pause(sender: AnyObject?) {
        if pause {
            pause = false
        } else {
            pause = true
        }
    }

    /// Handles launch button, launches the bubble in the cannon if no other bubbles are mid-air
    @IBAction func launchBubble(sender: AnyObject?) {
        gameEngine!.launch()
    }
    
    /// handles tap gesture on game area for selection of cannon angle
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


