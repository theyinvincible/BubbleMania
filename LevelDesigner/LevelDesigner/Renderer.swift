//
//  Renderer.swift
//  BubbleMania
//
//  Created by Jing Yin Ong on 13/2/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit

class Renderer {
    private var data: LevelDesign//[GridBubble]
    private var removedBubbles: [GridBubble]
    private var launchedBubble: ProjectileBubble?
    private var gameArea: UIView?
    private let frame: CGRect
    private let bubbleDiameter: CGFloat
    private var launchAngle: Double?
    private let numCols = 12
    private let heightRatio = CGFloat(6.7/8)
    
    private var needToRedrawGrid: Bool?
    private var storedGridView: UIView?
    
    private let redBubbleImage = UIImage(named: "bubble-red.png")
    private let orangeBubbleImage = UIImage(named: "bubble-orange.png")
    private let greenBubbleImage = UIImage(named: "bubble-green.png")
    private let blueBubbleImage = UIImage(named: "bubble-blue.png")
    private let explodingBubbleImage = UIImage(named: "explodingBubble.png")
    private let backgroundImage = UIImage(named: "background.png")
    
    init(data: LevelDesign, launchedBubble: ProjectileBubble, frame: CGRect, launchAngle: Double) {
        self.data = data
        self.launchedBubble = launchedBubble
        self.removedBubbles = [GridBubble]()
        self.frame = frame
        self.gameArea = UIView(frame: frame)
        self.launchAngle = launchAngle
        self.needToRedrawGrid = true
        bubbleDiameter = frame.size.width/CGFloat(numCols)
    }
    
    /// Updates the data to be drawn
    func update(data: LevelDesign, launchedBubble: ProjectileBubble, removedBubbles: [GridBubble], launchAngle: Double) {
        self.data = data
        self.launchedBubble = launchedBubble
        self.removedBubbles = removedBubbles
        self.launchAngle = launchAngle
        self.needToRedrawGrid = true
        self.gameArea = UIView(frame: frame)
        setBackgroundView()
    }
    
    func update(launchedBubble: ProjectileBubble, removedBubbles: [GridBubble], launchAngle: Double) {
        self.launchedBubble = launchedBubble
        self.removedBubbles = removedBubbles
        self.launchAngle = launchAngle
        self.needToRedrawGrid = false
        self.gameArea = UIView(frame: frame)
        setBackgroundView()
    }
    
    /// redraws scene based on existing information
    func redraw() -> UIView {
        
        // draw bubble grid with data
        var xPos, yPos: CGFloat
        if needToRedrawGrid! {
            storedGridView = redrawGrid()
        }
        gameArea!.addSubview(storedGridView!)
        
        // draw dashed lines indicating angle of launch
        redrawDashedLines()
        
        // draw projectile bubble
        xPos = CGFloat((launchedBubble?.getXPos())!)
        yPos = CGFloat((launchedBubble?.getYPos())!)
        let projectileBubbleView = UIView(frame: CGRectMake(xPos, yPos, bubbleDiameter, bubbleDiameter))
        initBubbleCellView(projectileBubbleView)
        setBubbleViewWithColor(projectileBubbleView, color: (launchedBubble?.getColor())!)
        gameArea?.addSubview(projectileBubbleView)
        
        // animate removal of bubbles
        for bubbleToBeRemoved in removedBubbles {
            // get position
            let row = bubbleToBeRemoved.getRow()
            let col = bubbleToBeRemoved.getCol()
            if row%2 == 0{
                xPos = CGFloat(col) * bubbleDiameter
            } else {
                xPos = (CGFloat(col) + CGFloat(0.5)) * bubbleDiameter
            }
            yPos = (CGFloat(row) * heightRatio * bubbleDiameter)
            
            let explodingBubbleView = UIView(frame: CGRectMake(xPos, yPos, bubbleDiameter, bubbleDiameter))
            explodingBubbleView.backgroundColor = UIColor(patternImage: scaleImage(explodingBubbleImage!, view: explodingBubbleView))
            gameArea!.addSubview(explodingBubbleView)
        }
        return gameArea!
    }
    
    /// Redraws the grid view
    /// - returns the grid view
    func redrawGrid() -> UIView {
        let gameAreaFrame = gameArea!.frame
        let gridView = BubbleGridView(frame: gameAreaFrame, gridDesign: data)
        return gridView
    }
    
    /// Redraws the dashed line indicating angle of launch
    func redrawDashedLines() {
        drawDashedLine(gameArea!.frame.width/2, startYPos: gameArea!.frame.height - bubbleDiameter/2, length: 300, angle: CGFloat(launchAngle!))
    }
    
    /// Draws a dashed line with the given parameters
    func drawDashedLine(startXPos: CGFloat, startYPos: CGFloat, length: CGFloat, angle: CGFloat) {
        let dashes: [CGFloat] = [8, 4]
        
        // set shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = CGRectMake(0, 0, gameArea!.frame.width, gameArea!.frame.height);
        shapeLayer.position = gameArea!.center
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
        
        gameArea!.layer.addSublayer(shapeLayer)
    }
    
    func setBackgroundView() {
        let backgroundImage = UIImage(named: "background.png")  //put into constants
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea!.frame.size.height
        let gameViewWidth = gameArea!.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea!.addSubview(background)
    }
    
    /// Draws the background
    /// - returns background view
    func drawBackgroundView(frame: CGRect) -> UIView {
        let view  = UIView.init(frame: frame)
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = view.frame.size.height
        let gameViewWidth = view.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        view.addSubview(background)
        return view
    }
    
    /// initialize bubble format of cell
    func initBubbleCellView(bubbleCell: UIView) {
        bubbleCell.layer.cornerRadius = bubbleCell.frame.size.width/2
        bubbleCell.clipsToBounds = true
        bubbleCell.layer.borderColor = UIColor.blackColor().CGColor
        bubbleCell.layer.borderWidth = 2.0
    }
    
    // Sets the view of the bubble to the color given in the parameter
    func setBubbleViewWithColor(bubbleView: UIView, color: BubbleColor) {
        switch color {
        case BubbleColor.red:
            bubbleView.backgroundColor = UIColor(patternImage: scaleImage(redBubbleImage!, view: bubbleView))
        case BubbleColor.orange:
            bubbleView.backgroundColor = UIColor(patternImage: scaleImage(orangeBubbleImage!, view: bubbleView))
        case BubbleColor.green:
            bubbleView.backgroundColor = UIColor(patternImage: scaleImage(greenBubbleImage!, view: bubbleView))
        case BubbleColor.blue:
            bubbleView.backgroundColor = UIColor(patternImage: scaleImage(blueBubbleImage!, view: bubbleView))
        default:
            break
        }
    }
    
    /// scales an image to fit the given view
    func scaleImage(image: UIImage, view: UIView) -> UIImage {
        let size = view.frame.size
        let hasAlpha = true
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

}