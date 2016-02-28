//
//  NewRenderer.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 28/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

class newRenderer {
    private var gridView: BubbleGridView
    private var removedBubbleViews = [BubbleView]()
    private var launchedBubble: ProjectileBubble
    private var gameArea: UIView
    private let frame: CGRect
    private let bubbleDiameter: CGFloat
   // private var launchAngle: Double
    private let numCols = 12
    private let heightRatio = CGFloat(6.7/8)
   // private var prelaunchBubbles: [ProjectileBubble]
    private var projectedTrajectory: CALayer?
    
    private var needToRedrawGrid: Bool?
    private var storedGridView: UIView?
    private var storedPrelaunchBubblesView = [BubbleView]()
    private var projectileBubbleView: BubbleView?
    private var animationCounter = 15
    private var animationCount = 15
    
    init(data: BubbleGrid, launchedBubble: ProjectileBubble, frame: CGRect) {//, prelaunchBubbles: [ProjectileBubble]) {
        self.gridView = BubbleGridView(frame: frame, gridDesign: data)
        self.launchedBubble = launchedBubble
        self.frame = frame
        self.gameArea = UIView(frame: frame)
        self.needToRedrawGrid = true
    //    self.prelaunchBubbles = prelaunchBubbles
        bubbleDiameter = frame.size.width/CGFloat(numCols)
        setBackgroundView()
        gameArea.addSubview(gridView)
    }
    
    func setBackgroundView() {
        let backgroundImage = UIImage(named: "background.png")  //put into constants
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
    }
    
    private var isLaunching = false
    func updateGrid(snappedBubble: GridBubble, removedBubbles: [GridBubble]) {
        isLaunching = false
        projectileBubbleView?.removeFromSuperview()
        gridView.addBubbleView(snappedBubble.getRow(), col: snappedBubble.getCol())
        gridView.getBubbleView(snappedBubble.getRow(), col: snappedBubble.getCol())?.setColor(snappedBubble.getColor())
        removedBubbleViews = [BubbleView]()
        print("are they empty \(removedBubbles.isEmpty)")
        for bubble in removedBubbles {
            print("converting bubble to bubbleview")
            let bubbleView = gridView.getBubbleView(bubble.getRow(), col: bubble.getCol())
            removedBubbleViews.append(bubbleView!)
        }
    }
    
    func updateLaunchedBubble(launchedBubble: ProjectileBubble) {
        isLaunching = true
        self.launchedBubble = launchedBubble
    }
    
    func updatePrelaunchBubbles(prelaunchBubbles: [ProjectileBubble]) {
        for prevBubbleView in storedPrelaunchBubblesView {
            prevBubbleView.removeFromSuperview()
        }
        storedPrelaunchBubblesView.removeAll()
        for i in 0..<prelaunchBubbles.count {
            let prelaunchBubble = prelaunchBubbles[i]
            let prelaunchBubbleView = BubbleView(frame: CGRectMake(CGFloat(2+i)*bubbleDiameter + gameArea.frame.width/2, gameArea.frame.height - bubbleDiameter, bubbleDiameter, bubbleDiameter), row: -1, col: -1)
            prelaunchBubbleView.setColor(prelaunchBubble.getColor())
            storedPrelaunchBubblesView.append(prelaunchBubbleView)
            gameArea.addSubview(prelaunchBubbleView)
        }
    }
    
    func redrawProjectedTrajectory(angle: Double) {
        if projectedTrajectory != nil {
            projectedTrajectory?.removeFromSuperlayer()
        }
        projectedTrajectory = drawDashedLine(gameArea.frame.width/2, startYPos: gameArea.frame.height - bubbleDiameter/2, length: 300, angle: CGFloat(angle))
    }
    
    func redraw() -> UIView {
        if removedBubbleViews.isEmpty {
            redrawLaunchedBubble()
        } else {        //never reset removedbubbles
            if projectileBubbleView?.superview != nil {
                projectileBubbleView!.removeFromSuperview()
            }
            /////// temporarily here for fast removal until i implement fading///////////
            
            for bubbleView in removedBubbleViews {
                print("here")
                gridView.removeBubbleViewAtPosition(bubbleView.getRow(), col: bubbleView.getCol())
            }
            removedBubbleViews.removeAll()
            ////////////////////////////////////////////////////////////////////////////
            if animationCounter == 0 {
                for bubbleView in removedBubbleViews {
                    gridView.removeBubbleViewAtPosition(bubbleView.getRow(), col: bubbleView.getCol())
                }
            } else if animationCounter < 5 {
                
            } else if animationCounter < 10 {
                
            } else {
                
            }
        }
        return gameArea
    }
    
    func redrawLaunchedBubble() {
        if projectileBubbleView != nil {
            projectileBubbleView!.removeFromSuperview()
        }
        if isLaunching{
            let xPos = CGFloat(launchedBubble.getXPos())
            let yPos = CGFloat(launchedBubble.getYPos())
            projectileBubbleView = BubbleView(frame: CGRectMake(xPos, yPos, bubbleDiameter, bubbleDiameter), row: -1, col: -1)
            projectileBubbleView!.setColor(launchedBubble.getColor())
            gameArea.addSubview(projectileBubbleView!)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /// Draws a dashed line with the given parameters
    func drawDashedLine(startXPos: CGFloat, startYPos: CGFloat, length: CGFloat, angle: CGFloat) -> CALayer {
        let dashes: [CGFloat] = [8, 4]
        
        // set shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = CGRectMake(0, 0, gameArea.frame.width, gameArea.frame.height);
        shapeLayer.position = gameArea.center
        shapeLayer.strokeStart = 0.0;
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = dashes
        shapeLayer.lineDashPhase = 3.0
        
        // set path
        let path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, startXPos, startYPos)
        CGPathAddLineToPoint(path, nil, length*cos(angle) + startXPos, startYPos - length*sin(angle))
        shapeLayer.path = path
        
        gameArea.layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
}
