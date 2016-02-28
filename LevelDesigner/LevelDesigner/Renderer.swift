//
//  NewRenderer.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 28/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation
import UIKit

/// Renders the screen for game play
class Renderer {
    private var gridView: BubbleGridView
    private var removedBubbleViews = [BubbleView]()
    private var launchedBubble: ProjectileBubble
    private var gameArea: UIView
    private let frame: CGRect
    private let bubbleDiameter: CGFloat
    private var projectedTrajectory: CALayer?
    private var isLaunching = false

    private var storedGridView: UIView?
    private var storedPrelaunchBubblesView = [BubbleView]()
    private var projectileBubbleView: BubbleView?
    private var animationCounter = Constants.animationCount
    
    init(data: BubbleGrid, launchedBubble: ProjectileBubble, frame: CGRect) {//, prelaunchBubbles: [ProjectileBubble]) {
        self.gridView = BubbleGridView(frame: frame, gridDesign: data)
        self.launchedBubble = launchedBubble
        self.frame = frame
        self.gameArea = UIView(frame: frame)
        bubbleDiameter = frame.size.width/CGFloat(Constants.gridNumColsForEvenRow)
        setBackgroundView()
        gameArea.addSubview(gridView)
    }
    
    /// sets the background image of the play screen
    func setBackgroundView() {
        let backgroundImage = Constants.backgroundImage!
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
    }
    
    /// updates the renderer on bubbles that have been snapped to/removed from the grid
    func updateGrid(snappedBubble: GridBubble, removedBubbles: [GridBubble]) {
        isLaunching = false
        projectileBubbleView?.removeFromSuperview()
        let snappedBubbleView = gridView.addBubbleView(snappedBubble.getRow(), col: snappedBubble.getCol())
        snappedBubbleView.setColor(snappedBubble.getColor())
        removedBubbleViews = [BubbleView]()
        for bubble in removedBubbles {
            let bubbleView = gridView.getBubbleView(bubble.getRow(), col: bubble.getCol())
            removedBubbleViews.append(bubbleView!)
        }
    }
    
    /// updates the renderer on the bubble being launched
    func updateLaunchedBubble(launchedBubble: ProjectileBubble) {
        isLaunching = true
        self.launchedBubble = launchedBubble
    }
    
    /// updates the renderer on the bubbles to be previewed, which the renderer then displays
    func updatePrelaunchBubbles(prelaunchBubbles: [ProjectileBubble]) {
        // remove display of previous launch bubbles preview
        for prevBubbleView in storedPrelaunchBubblesView {
            prevBubbleView.removeFromSuperview()
        }
        storedPrelaunchBubblesView.removeAll()
        // displays the new set of preview launch bubbles
        for i in 0..<prelaunchBubbles.count {
            let prelaunchBubble = prelaunchBubbles[i]
            let prelaunchBubbleView = BubbleView(frame: CGRectMake(CGFloat(2+i)*bubbleDiameter + gameArea.frame.width/2, gameArea.frame.height - bubbleDiameter, bubbleDiameter, bubbleDiameter), row: -1, col: -1)
            prelaunchBubbleView.setColor(prelaunchBubble.getColor())
            storedPrelaunchBubblesView.append(prelaunchBubbleView)
            gameArea.addSubview(prelaunchBubbleView)
        }
    }
    
    /// draws a dashed line indicating the potential trajectory of a bubble when it is launched, based on the angle that was chosen
    func redrawProjectedTrajectory(angle: Double) {
        if projectedTrajectory != nil {
            projectedTrajectory?.removeFromSuperlayer()
        }
        projectedTrajectory = drawDashedLine(gameArea.frame.width/2, startYPos: gameArea.frame.height - bubbleDiameter/2, length: 300, angle: CGFloat(angle))
    }
    
    /// returns the view of the game screen
    func redraw() -> UIView {
        if removedBubbleViews.isEmpty {
            redrawLaunchedBubble()
        } else {
            if projectileBubbleView?.superview != nil {
                projectileBubbleView!.removeFromSuperview()
            }
            // animates removal of bubbles, which fades away
            if animationCounter == 0 {
                for bubbleView in removedBubbleViews {
                    gridView.removeBubbleViewAtPosition(bubbleView.getRow(), col: bubbleView.getCol())
                }
                removedBubbleViews.removeAll()
                animationCounter = Constants.animationCount
            } else if animationCounter < Constants.animationCount/3 {
                for bubbleView in removedBubbleViews {
                    bubbleView.alpha = Constants.thirdPhaseAlpha
                }
            } else if animationCounter < (2 * Constants.animationCount)/3 {
                for bubbleView in removedBubbleViews {
                    bubbleView.alpha = Constants.secondPhaseAlpha
                }
            } else {
                for bubbleView in removedBubbleViews {
                    bubbleView.alpha = Constants.firstPhaseAlpha
                }
            }
            animationCounter--
        }
        return gameArea
    }
    
    /// draws the projectile bubble that is being launched
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
